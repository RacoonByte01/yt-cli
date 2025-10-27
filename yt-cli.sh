#!/bin/bash

PATH_SUBSCRIBED_CHANNELS=./subscribed_channels
MAIN_MENU=-1

menu(){
	echo -en "$1" | sh -c "fzf $2" | awk -F: '{printf $1}'
}

subscribed_menu(){
	[[ -f $PATH_SUBSCRIBED_CHANNELS ]] || touch $PATH_SUBSCRIBED_CHANNELS
	SUBSCRIBED_CHANNEL_SELECTED=-1
	SUBSCRIBED_CHANNELS=$SUBSCRIBED_CHANNELS$(echo "0: <-- Return";cat $PATH_SUBSCRIBED_CHANNELS)
	# cat $PATH_SUBSCRIBED_CHANNELS | fzf --header "Select channel to see or add them in path=$PATH_SUBSCRIBED_CHANNELS"
	menu "$SUBSCRIBED_CHANNELS" "--header \"Select channel to see or add them in path=$PATH_SUBSCRIBED_CHANNELS\""
}

main_menu()
{
	shift; menu '0: News!\n1: Subscribed\n2: Stored\n3: Settings\n4: Close' "--header 'Select an option' --preview='figlet -f ANSI\ Shadow Hi again :3'"
}

while [[ "$MAIN_MENU" -ne "4" ]]; do
	MAIN_MENU=$(main_menu)
	case "$MAIN_MENU" in
		1) shift; subscribed_menu
		;;
	esac
done
