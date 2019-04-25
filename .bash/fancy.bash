#!/usr/bin/env bash

# This is sort've a franken-bash, mostly because I only barely
# know what I'm doing. If you have any ideas or insight, please
# let me know what's up!

# https://linux.101hacks.com/ps1-examples/prompt-color-using-tput/
# https://wiki.archlinux.org/index.php/Bash/Prompt_customization#Techniques
# https://misc.flogisoft.com/bash/tip_colors_and_formatting

_reset_()
{
	printf "\e(B\e[m"
}

# Foreground Color
_fg_()
{
	printf "\e[3%sm" "$1"
}

# Background Color
_bg_()
{
	printf "\e[4%sm" "$1"
}

_highlight_()
{
	printf "\e[7m"
}

_nohighlight_()
{
	printf "\e[27m"
}

_bold_()
{
	printf "\e[1m"
}

_nobold_()
{
	printf "\e[21m"
}

_italic_()
{
	printf "\e[3m"
}

_noitalic_()
{
	printf "\e[23m"
}

_underline_()
{
	printf "\e[4m"
}

_nounderline_()
{
	printf "\e[24m"
}

_dim_()
{
	printf "\e[2m"
}

_nodim_()
{
	printf "\e[22m"
}

_blink_()
{
	printf "\e[5m"
}

_noblink_()
{
	printf "\e[25m"
}

_black_()
{
	_fg_ 0
}

_red_()
{
	_fg_ 1
}

_green_()
{
	_fg_ 2
}

_yellow_()
{
	_fg_ 3
}

_blue_()
{
	_fg_ 4
}

_magenta_()
{
	_fg_ 5
}

_cyan_()
{
	_fg_ 6
}

_white_()
{
	_fg_ 7
}

_black_bg_()
{
	_bg_ 0
}

_red_bg_()
{
	_bg_ 1
}

_green_bg_()
{
	_bg_ 2
}

_yellow_bg_()
{
	_bg_ 3
}

_blue_bg_()
{
	_bg_ 4
}

_magenta_bg_()
{
	_bg_ 5
}

_cyan_bg_()
{
	_bg_ 6
}

_white_bg_()
{
	_bg_ 7
}

