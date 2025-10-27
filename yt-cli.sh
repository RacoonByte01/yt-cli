#!/bin/bash

PATH_SUBSCRIBED_CHANNELS=./subscribed_channels
MAIN_MENU=-1
BASE='https://www.youtube.com/@'

menu()
{
	echo -en "$1" | sh -c "fzf --style full $2" | awk -F: '{printf $'$3'}'
}

open_video()
{
	local OPTION=$(echo -en "󰌑 Return\n See\n Music mode\n󰇚 Download\n󰐒 Save to list" | fzf --style full --header 'Video options...')
	if [[ "$OPTION" == " See" ]]; then
		# Save History
		mpv --fullscreen "$1"
	elif [[ "$OPTION" == " Music mode" ]]; then
		mpv --no-video "$1"
	fi
}

get_youtube()
{
	if [[ $1 -eq 0 ]]; then
		NUM_SELECTED=$(( echo "󰌑 Return"; yt-dlp --flat-playlist "$BASE$2/$3" --playlist-end 1000 --print "%(playlist_index)d: %(title)s" ) | fzf --style full --header "Select the desired $3" | awk -F: '{print $1}')
		if [[ $NUM_SELECTED == "󰌑 Return" ]]; then
			echo "󰌑 Return"
		else
			yt-dlp --flat-playlist "$BASE$2/$3" --print url --playlist-items $NUM_SELECTED
		fi
	else
		NUM_SELECTED=$(( echo "󰌑 Return"; echo "󰐑 See all"; echo "󰲹 Music mode all"; echo "󰇚 Download all"; echo "󰐒 Save list"; yt-dlp --flat-playlist "$2" --print "%(playlist_index)d: %(title)s" ) | fzf --style full --header "Select the desired videos" | awk -F: '{print $1}')
		if [ "$NUM_SELECTED" = '󰌑 Return' ] || [ "$NUM_SELECTED" = "󰐑 See all" ] || [ "$NUM_SELECTED" = "󰲹 Music mode all" ] || [ "$NUM_SELECTED" = "󰇚 Download all" ] || [ "$NUM_SELECTED" = "󰐒 Save list" ]; then
			echo $NUM_SELECTED
		else
			yt-dlp --flat-playlist "$2" --print url --playlist-items $NUM_SELECTED
		fi
	fi
}

type_media_search_menu()
{
	echo -en "󰌑 Return\n videos\n󰐑 playlists\n streams\n shorts"  | fzf --style full --header 'What content do you want?' | awk '{print $2}'
}

subscribed_menu()
{
	[[ -f $PATH_SUBSCRIBED_CHANNELS ]] || touch $PATH_SUBSCRIBED_CHANNELS
	local SUBSCRIBED_CHANNEL_SELECTED=-1
	local TYPE_MEDIA_SEARCH_SELECTED=-1
	local SUBSCRIBED_CHANNELS=$SUBSCRIBED_CHANNELS$(echo "󰌑 Return";cat $PATH_SUBSCRIBED_CHANNELS)
	while [[ "$SUBSCRIBED_CHANNEL_SELECTED" != "󰌑 Return" ]]; do
		SUBSCRIBED_CHANNEL_SELECTED=$(menu "$SUBSCRIBED_CHANNELS" "--header \"Select channel to see or add them in path=$PATH_SUBSCRIBED_CHANNELS\"" 1)
		if [[ "$SUBSCRIBED_CHANNEL_SELECTED" != "󰌑 Return" ]]; then
			TYPE_MEDIA_SEARCH_SELECTED=-1
			while [[ $TYPE_MEDIA_SEARCH_SELECTED != "Return" ]]; do
				TYPE_MEDIA_SEARCH_SELECTED=$(type_media_search_menu)
				if [[ "$TYPE_MEDIA_SEARCH_SELECTED" == playlists ]]; then
					local URL_PLAYLIST=-1
					while [[ "$URL_PLAYLIST" != "󰌑 Return" ]]; do
						URL_PLAYLIST=$(shift; get_youtube 0 $SUBSCRIBED_CHANNEL_SELECTED $TYPE_MEDIA_SEARCH_SELECTED)
						if [[ "$URL_PLAYLIST" != "󰌑 Return" ]]; then
							local URL=$(get_youtube 1 "$URL_PLAYLIST")
							if [[ "$URL" != "󰌑 Return" ]]; then
								shift; open_video $URL
							fi
						fi
					done
				elif [[ $TYPE_MEDIA_SEARCH_SELECTED != "Return" ]]; then
					local URL=-1
					while [[ "$URL" != "󰌑 Return" ]]; do
						URL=$(shift; get_youtube 0 $SUBSCRIBED_CHANNEL_SELECTED $TYPE_MEDIA_SEARCH_SELECTED)
						if [[ "$URL" != "󰌑 Return" ]]; then							
							shift; open_video "$URL"
						fi
					done
				fi
			done

		fi
		
	done
}

main_menu()
{
	shift; menu "0:  News!\n1: 󰵀 Subscribed\n2:  Stored\n3:  Settings\n4:  Close" "--header 'Select an option'" 1
}

while [[ "$MAIN_MENU" -ne "4" ]]; do
	MAIN_MENU=$(main_menu)
	case "$MAIN_MENU" in
		1) shift; subscribed_menu
		;;
	esac
done
