#!/usr/bin/env bash
# shellcheck disable=SC2002
# https://www.shellcheck.net

kill_space_engineers() {
	# grab the PIDs of SpaceEngineers. There might be more than one from multiple sessions...
	#
	# we can also list the threads using -eLo
	# but that's not needed since `kill -9 ${pid}` will kill the whole
	# process including the threads.
	#
	# Note that it's a process which sets the name of its thread to
	# its process file name, "SpaceEngineers.exe". However, most kernels
	# have a 15 character limit for thread names, so it gets truncated.
	# See also: https://stackoverflow.com/a/5026997/1111557
	#
	# The 16 character limit (15 + null byte) truncates it to the dot.
	# How annoyingly convenient.
	mapfile -t sePids < <(
		ps -eo pid,ppid,comm \
		| tr -s ' ' \
		| grep -P 'SpaceEngineers\.( <defunct>)?$' \
		| sed -r 's/^ *//g'
	)
	#
	# If no SpaceEngineers pids were found then maybe the bug was already
	# fixed or you did a partial cleanup yourself. I don't want to risk
	# killing something else accidentally, so report and exit.
	if [[ "${#sePids[@]}" -eq "0" ]]
	then
		echo "No SpaceEngineers processes found. Did you try a partial cleanup already?"
		return 0 # EXIT_SUCCESS
	fi
	echo "sePids: ${sePids[@]}"

	#
	# The whole process tree of the parent of SpaceEngineers needs to die.
	# The parent process must be Steam. It is, specifically, the
	# SteamChildMonit process. However, if we just kill the parent then
	# Steam itself will inherit the SteamChildMonit children (such as
	# SpaceEngineers.exe, winedevice.exe, python3, etc...), and Steam
	# itself won't know to `wait()` for those pids. So we have to
	# tell each process in that tree to die.
	#
	# As a sanity check, we will filter the ppid against expectations.
	# We don't want to accidentally `kill` the wrong things!
	mapfile -d ' ' -t seParentPidCandidates < <(
		echo "${sePids[@]}" \
		| cut -d ' ' -f 2 \
		| sed -rz 's/\s+/ /g'
	)
	echo "seParentPidCandidates: ${seParentPidCandidates[@]}"
	mapfile -t seSteamChildMonitPids < <(
		# Collapse the candidates to a single line, separated by spaces.
		# Then, `ps` will want commas while `grep -P` will want pipes.
		candidates="$(echo -n "${seParentPidCandidates[@]}")"
		candidatesByComma="$(echo -n "${candidates}" | sed -r 's/ /,/g')"
		candidatesByPipe="$(echo -n "${candidates}" | sed -r 's/ /|/g')"
		#
		# list those processes,
		# then filter to SteamChildMonit (again, 15 character thread name limit...)
		# then filter to just the pids with whitespace
		# then filter to just the pids
		#
		# Importantly, '\s*' is needed because the pids are right-aligned
		# and you might have eg pid=999 and pid=1000, and so 999 would
		# have a space prefixed. and 1000 would not.
		#
		ps \
			-eo pid,comm \
			-q "${candidatesByComma}" \
		| tr -s ' ' \
		| sed -r 's/^ *//g' \
		| grep -P "^(${candidatesByPipe}) SteamChildMonit$" \
		| grep -oP '^\d+'
		#
		# Also, if you already killed the SteamChildMonit, then SpaceEngineers
		# is now possibly owned by pid 1. pid 1 was almost certainled filtered
		# out. If so, that's fine too. If we echo the SpaceEngineers pid(s), then
		# that will prevent us from erroring out so that we at least kill the
		# SpaceEngineers pids.
		echo -n "${sePids[@]}" \
		| cut -d ' ' -f 1
	)
	echo "seSteamChildMonitPids: ${seSteamChildMonitPids[@]}"
	#
	# Okay, now find all children of the SteamChildMonit processes
	mapfile -t seRelatedPids < <(
		cat <(
			byPipeForRegex="$(
				echo -n "${seSteamChildMonitPids[@]}" \
				| sed -r 's/ /|/g'
			)"
			ps \
				-eo pid,ppid \
			| tr -s ' ' \
			| sed -r 's/^ +//g' \
			| grep -P "^\d+ (${byPipeForRegex})$" \
			| cut -d ' ' -f 1
		) <(echo -n "${seSteamChildMonitPids[@]}") \
		| sed -r 's/ /\n/g' \
		| sort -gu # sort just for debugging
	)
	if [[ "${#seRelatedPids[@]}" -eq "0" ]]
	then
		>&2 echo "PIDs vanished! Hopefully that's good. Maybe the script is broken though."
		return 1 # EXIT_FAILURE
	fi
	echo "seRelatedPids: ${seRelatedPids[@]}"
	#
	# And now, kill all the bast...err...processes.
	# Also if you don't like -9 (SIGKILL) then KMA.
	echo "I am going to kill these processes!"
	ps -o pid,user,command -q "$(echo "${seRelatedPids[@]}" | sed -r 's/ /,/g')"
	echo "Check that only Steam, Space Engineers, and wine related PIDs are seen."
	echo "Kill? y/n: "
	IFS='' read -r line
	if [[ "${line}" != "y" ]]
	then
		echo "'y' wasn't entered. I guess we're being graceful today."
		return 0
	fi
	echo kill -9 "${seRelatedPids[@]}"
	kill -9 "${seRelatedPids[@]}"
}

