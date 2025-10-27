#!/bin/bash

PATH_SUBSCRIBED_CHANNELS=./subscribed_channels
MAIN_MENU=-1
BASE='https://www.youtube.com/@'

menu()
{
	echo -en "$1" | sh -c "fzf $2" | awk -F: '{printf $1}'
}

get_youtube()
{
	if [[ $1 -eq 0 ]]; then
		NUM_SELECTED=$(( echo "󰌑 Return"; yt-dlp --flat-playlist "$BASE$2/$3" --print "%(playlist_index)d: %(title)s" ) | fzf --header "Select the desired $3" | awk -F: '{print $1}')
		if [[ $NUM_SELECTED == "󰌑 Return" ]]; then
			echo "󰌑 Return"
		else
			yt-dlp --flat-playlist "$BASE$2/$3" --print url --playlist-items $NUM_SELECTED
		fi
	else
		( echo "󰌑 Return"; echo "󰐑 See all"; echo "󰲹 Music mode all"; echo "󰇚 Download all"; echo "󰐒 Save List"; yt-dlp --flat-playlist "$2" --print "%(playlist_index)d: %(title)s" ) | fzf --header "Select the desired videos"
	fi
}

type_media_search_menu()
{
	menu "videos\nplaylists\nstreams\nshorts" "--header 'What content do you want?'"
}

subscribed_menu()
{
	[[ -f $PATH_SUBSCRIBED_CHANNELS ]] || touch $PATH_SUBSCRIBED_CHANNELS
	local SUBSCRIBED_CHANNEL_SELECTED=-1
	local TYPE_MEDIA_SEARCH_SELECTED=-1
	local SUBSCRIBED_CHANNELS=$SUBSCRIBED_CHANNELS$(echo "󰌑 Return";cat $PATH_SUBSCRIBED_CHANNELS)
	while [[ "$SUBSCRIBED_CHANNEL_SELECTED" != "󰌑 Return" ]]; do
		SUBSCRIBED_CHANNEL_SELECTED=$(menu "$SUBSCRIBED_CHANNELS" "--header \"Select channel to see or add them in path=$PATH_SUBSCRIBED_CHANNELS\"")
		if [[ "$SUBSCRIBED_CHANNEL_SELECTED" != "󰌑 Return" ]]; then
			TYPE_MEDIA_SEARCH_SELECTED=$(type_media_search_menu)
			if [[ "$TYPE_MEDIA_SEARCH_SELECTED" == playlists ]]; then
				local URL_PLAYLIST=-1
				while [[ "$URL_PLAYLIST" != "󰌑 Return" ]]; do
					URL_PLAYLIST=$(shift; get_youtube 0 $SUBSCRIBED_CHANNEL_SELECTED $TYPE_MEDIA_SEARCH_SELECTED)
					if [[ "$URL_PLAYLIST" != "󰌑 Return" ]]; then
						shift; get_youtube 1 "$URL_PLAYLIST"
					fi
				done
			fi
		fi
		
	done
}

main_menu()
{
	shift; menu "0:  News!\n1: 󰵀 Subscribed\n2:  Stored\n3:  Settings\n4:  Close" "--header 'Select an option'"
}

while [[ "$MAIN_MENU" -ne "4" ]]; do
	MAIN_MENU=$(main_menu)
	case "$MAIN_MENU" in
		1) shift; subscribed_menu
		;;
	esac
done
