#!/bin/bash

PATH_SUBSCRIBED_CHANNELS=./subscribed_channels
MAIN_MENU=-1

menu(){
	echo -en "$1" | sh -c "fzf $2" | awk -F: '{printf $1}'
}

type_media_search_menu()
{
	menu "videos\nplaylists\nstreams\nshorts" "--header 'What content do you want?'"
}

subscribed_menu(){
	[[ -f $PATH_SUBSCRIBED_CHANNELS ]] || touch $PATH_SUBSCRIBED_CHANNELS
	local SUBSCRIBED_CHANNEL_SELECTED=-1
	local TYPE_MEDIA_SEARCH_SELECTED=-1
	local SUBSCRIBED_CHANNELS=$SUBSCRIBED_CHANNELS$(echo "0: <-- Return";cat $PATH_SUBSCRIBED_CHANNELS)
	while [[ "$SUBSCRIBED_CHANNEL_SELECTED" != "0" ]]; do
		SUBSCRIBED_CHANNEL_SELECTED=$(menu "$SUBSCRIBED_CHANNELS" "--header \"Select channel to see or add them in path=$PATH_SUBSCRIBED_CHANNELS\"")
		if [[ "$SUBSCRIBED_CHANNEL_SELECTED" != "0" ]]; then
			TYPE_MEDIA_SEARCH_SELECTED=$(type_media_search_menu)
		fi
	done
}

main_menu()
{
	shift; menu "0: News!\n1: Subscribed\n2: Stored\n3: Settings\n4: Close" "--header 'Select an option' --preview='figlet -f ANSI\ Shadow Hi again :3'"
}

while [[ "$MAIN_MENU" -ne "4" ]]; do
	MAIN_MENU=$(main_menu)
	case "$MAIN_MENU" in
		1) shift; subscribed_menu
		;;
	esac
done
