#!/bin/bash

while true
do
	COLUMNS=$(tput cols)
	DATE=$(date)
	WHITESPACE=$(( COLUMNS - ${#DATE} ))

	# \e[10000D erases current line (backspace 10k times)
	# print date, then whitespace (overwrite any previous junk from accidental typing during the clock display)
	# then backspace to beginning of line to any further accidental typing is unlikely to cause newlines
	# unless you're silly enough to paste a bunch of garbage
	printf "\e[10000D%s%${WHITESPACE}s\e[10000D" "${DATE}" " "
	sleep 1
done
#	echo -en "\e[10000D$(date)"; sleep 1; done

