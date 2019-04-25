# .bashrc

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# Load bash completions
# Some completions query pkg-config, so set that now.
PKG_CONFIG_PATH="${HOME}"/.local/share/pkg-config"${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"
export PKG_CONFIG_PATH
. $HOME/.local/share/bash-completion/bash_completion

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --color=auto'

[ -n "$TERM" ] && alias htop='TERM=screen htop'

[ -f "$HOME/.local/bin/nginx-logs.sh" ] && alias nginx-logs='sudo $HOME/.local/bin/nginx-logs.sh'

if [ -f "/bin/firewall-cmd" ] || [ -f "/usr/sbin/csf" ]; then
  deny_ip_add() {
    [ "$1" == "" ] && printf "\033[1;31mYou must specify an IP address to block.\033[0;0m\n" && return 1
    [ -f "/bin/firewall-cmd" ] &&
      /usr/bin/sudo /bin/firewall-cmd --zone="drop" --add-source="$1" &&
      /usr/bin/sudo /bin/firewall-cmd --permanent --zone="drop" --add-source="$1" 1>/dev/null
    [ -f "/usr/sbin/csf" ] &&
      /usr/bin/sudo /usr/sbin/csf -d "$1"
  }
  deny_ip_remove() {
    [ "$1" == "" ] && printf "\033[1;31mYou must specify an IP address to unblock.\033[0;0m\n" && return 1
    [ -f "/bin/firewall-cmd" ] &&
      /usr/bin/sudo /bin/firewall-cmd --zone="drop" --remove-source="$1" &&
      /usr/bin/sudo /bin/firewall-cmd --permanent --zone="drop" --remove-source="$1" 1>/dev/null
    [ -f "/usr/sbin/csf" ] &&
      /usr/bin/sudo /usr/sbin/csf -dr "$1"
  }
  alias firewall-deny=deny_ip_add
  alias firewall-denyr=deny_ip_remove
fi

[ -x "$(which vim)" ] || { >&2 printf "\033[1;31mwarning\033[0;31m: vim not found~\033[0;0m\n"; }
export EDITOR="$(which vim)"
export VISUAL="${EDITOR}"


# Better prompt for shell, but only set if PS1 has already been set (PS1 is not set for non-interactive sessions)
source "${HOME}/.bash/fancy.bash"
prompt_previous_process_status()
{
	case "$1" in
	0) _green_;;
	*) _red_ && _bold_;;
	esac
	return "$1"
}
if [ -n "$PS1" ]
then
	# Bash wants to count the number of characters in the prompt.
	# In order to do that, it needs to know which characters are
	# control characters so it doesn't count them in the width.
	# To do that, the control characters must be wrapped in
	# escaped square brackets.
	#
	# It also seems that the brackets must be directly in the string
	# assigned to PS1, and not emitted from a subshell. So for
	# example, prompt_previous_process_status can emit EITHER the
	# control characters OR the status code. Ugh. Further complicating
	# is that the function gets called at print time, which garbles
	# the previous process's exit status later; workaround for that
	# is fairly straightfoward: just return the same exit code.
	#
	# The control characters are emitted from the functions in
	# fancy.bash.
	#
	# One object per line here. Using a heredoc with escaped
	# newlines to concatenate the complexity to a single line.
	PS1=$(cat <<EOF
\[$(_reset_)\]\
\[$(_red_)\][ \
\[$(_italic_)$(_blue_)\]\D{%F}T\D{%T}\D{%z}\
\[$(_noitalic_)$(_red_)\] \
\[$(_red_)\]]\

\[$(_red_)\][\
\[\$(prompt_previous_process_status \$?)\]\$(printf '%3.3s' \$?)\[$(_reset_)\] \
\[$(_highlight_)\]\\\$\[$(_nohighlight_)\] \
\[$(_yellow_)\]\u\
\[$(_green_)\]@\
\[$(_blue_)\]\h\
\[$(_green_)\]:\
\[$(_magenta_)\]\w\
\[$(_red_)\]] \
\[$(_reset_)\]
EOF
)
	export PS1
fi

# KeithB: fix Terminal titles with a new prompt
export PROMPT_COMMAND='echo -en "\033]0;$(whoami)@$(hostname):${PWD}\a"'

[ -x /usr/bin/dircolors ] && [ -s ~/.dir_colors ] && eval "$(/usr/bin/dircolors ~/.dir_colors)"

# Shell history settings
export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=10000                   # big history
export HISTFILESIZE=10000               # big history
shopt -s histappend                     # append to history, don't overwrite it
shopt -s checkwinsize                   # update LINES and COLUMNS after every command

# Save and reload the history after each command finishes
# export PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"

# KeithB: default is `ulimit -c 0` -- But I want to always allow core dumps for debugging.
ulimit -c unlimited

# KeithB: GCC colors are beautiful and helpful
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# KeithB: have git print the status of the profile upon login.
# Note: this can break non-interactive sessions (such as scp and sftp), so check PS1
[ ! -z "${PS1}" ] && [ "${PWD}" == "${HOME}" ] && git status

# KeithB: load .profile (local machine profile) if it exists
[ -f "${HOME}/.profile" ] && . "${HOME}/.profile"

# KeithB: .bash_aliases loads stuff from ~/.bash
source ~/.bash_aliases

# KeithB: Fix issue with Fedora 25 Cinnamon not opening new Terminal tabs in CWD
[ -f /etc/profile.d/vte.sh ] && . /etc/profile.d/vte.sh

# KeithB: from `man gpg-agent` to work with PGP smart cards via gpg2
GPG_TTY=$(tty)
export GPG_TTY

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]
then
	export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
fi

export PATH="/opt/kitware/cmake/v3.12.2/bin:${PATH}"
export BOOST_ROOT=/opt/boost/current
export DOTNET_CLI_TELEMETRY_OPTOUT=1

source "${HOME}/.bash/garbage-executables.bash"

