#!/bin/bash

PATH_SUBSCRIBED_CHANNELS=./subscribed_channels
MAIN_MENU=-1
BASE='https://www.youtube.com/@'

# Make a menu by:
# * $1: Menu items separated by `\n`.
# * $2: Get the flags that fzf will have.
# * $3: The desired menu item separated by `:`.
# * Return: The number menu selected.
#  TODO: Make the menus that load from yt-dlp load with the function for the loading bar.
menu()
{
	echo -en "$1" | sh -c "fzf --style full $2" | awk -F: '{printf $'"$3"'}'
}

# Allows you to open a video from a URL.
# Returns the video player process with the URL
open_video()
{
	OPTION=$(echo -en "󰌑 Return\n See\n Music mode\n󰇚 Download\n󰐒 Save to list" | fzf --style full --header 'Video options...')
	if [[ "$OPTION" == " See" ]]; then
		#  TODO: Save History
		mpv --fullscreen "$1"
	elif [[ "$OPTION" == " Music mode" ]]; then
		mpv --no-video "$1"
	fi
}

# Allows you to search for content on YouTube.
# * $1 Type of search 0==content{chanel:video, chanel:playlist, ...}; 1==URL.
# * $2 | $1==0 name of chanel | $2==1 URL.
# * $3 | $1==0 type content {video, playlist, ...} | $1==1 nothing.
# Return URL of video.
get_youtube()
{
	if [[ $1 -eq 0 ]]; then
		NUM_SELECTED=$(fzf --style full --header "Select the desired $3" --bind "start,ctrl-r:reload:echo \"󰌑 Return\"; i=0; while [[ \"\$i\" != \"-1\" ]]; do feed=\$(yt-dlp -i -q --flat-playlist \"$BASE$2/$3\" --playlist-start \$((\$i*100+1)) --playlist-end \$((\$i*100+100)) --print \"%(playlist_index)d: %(title)s\"); i=\$((\$i+1)); [[ \"\$feed\" != \"\" ]] && echo \$feed; [[ \"\$(echo \$feed | wc -l)\" -lt \"100\" ]] && i=-1; done" | awk -F: '{print $1}')
		case "$NUM_SELECTED" in
			"󰌑 Return"|"")
				echo "󰌑 Return"
			;;
			*)
				yt-dlp -q --ignore-errors --no-warnings --flat-playlist "$BASE$2/$3" --print url --playlist-items "$NUM_SELECTED" 2> /dev/null
			;;
		esac
	else
		NUM_SELECTED=$( ( echo "󰌑 Return"; echo "󰐑 See all"; echo "󰲹 Music mode all"; echo "󰇚 Download all"; echo "󰐒 Save list"; yt-dlp -q --ignore-errors --no-warnings --flat-playlist "$2" --print "%(playlist_index)d: %(title)s" 2> /dev/null ) | fzf --style full --header "Select the desired videos" | awk -F: '{print $1}')
		case "$NUM_SELECTED" in
			"󰐑 See all"|"󰲹 Music mode all"|"󰇚 Download all"|"󰐒 Save list")
				echo "$NUM_SELECTED"
				;;
			"󰌑 Return"|"")
				echo "󰌑 Return"
				;;
			*)
				yt-dlp -q --ignore-errors --no-warnings --flat-playlist "$2" --print url --playlist-items "$NUM_SELECTED" 2> /dev/null
				;;
		esac
	fi
}

# Create a menu to know what type of content you want from a channel.
# Returns the content you want to see {videos, playlists, ...}.
type_media_search_menu()
{
	echo -en "󰌑 Return\n videos\n󰐑 playlists\n streams\n shorts" | fzf --style full --header 'What content do you want?' | awk '{print $2}'
}

# Perform all necessary actions to obtain the video playlist ... from a subscribed channel.
# Returns the video player process with the desired URL.
subscribed_menu()
{
	[[ -f $PATH_SUBSCRIBED_CHANNELS ]] || touch $PATH_SUBSCRIBED_CHANNELS
	SUBSCRIBED_CHANNEL_SELECTED=-1
	SUBSCRIBED_CHANNELS=$SUBSCRIBED_CHANNELS$(echo "󰌑 Return";sort $PATH_SUBSCRIBED_CHANNELS)
	while ! { [ "$SUBSCRIBED_CHANNEL_SELECTED" == "󰌑 Return" ] || [ "$SUBSCRIBED_CHANNEL_SELECTED" == "" ]; }; do
		SUBSCRIBED_CHANNEL_SELECTED=$(menu "$SUBSCRIBED_CHANNELS" "--header \"Select channel to see or add them in path=$PATH_SUBSCRIBED_CHANNELS\"" 1)
		if ! { [ "$SUBSCRIBED_CHANNEL_SELECTED" == "󰌑 Return" ] || [ "$SUBSCRIBED_CHANNEL_SELECTED" == "" ]; }; then
			TYPE_MEDIA_SEARCH_SELECTED=-1
			while [[ $TYPE_MEDIA_SEARCH_SELECTED != "Return" ]]; do
				TYPE_MEDIA_SEARCH_SELECTED=$(type_media_search_menu)
				case "$TYPE_MEDIA_SEARCH_SELECTED" in
					"Return"|"")
						TYPE_MEDIA_SEARCH_SELECTED="Return"
						;;
					"playlists")
						local URL_PLAYLIST=-1
						while [[ "$URL_PLAYLIST" != "󰌑 Return" ]]; do
							URL_PLAYLIST=$(shift; get_youtube 0 "$SUBSCRIBED_CHANNEL_SELECTED" "$TYPE_MEDIA_SEARCH_SELECTED")
							if [[ "$URL_PLAYLIST" != "󰌑 Return" ]]; then
								local URL=-1
								while [[ "$URL" != "󰌑 Return" ]]; do
									URL=$(get_youtube 1 "$URL_PLAYLIST")
									if [[ "$URL" != "󰌑 Return" ]]; then
										shift; open_video "$URL"
									fi
								done
							fi
						done
						;;
					*)
						local URL=-1
						while [[ "$URL" != "󰌑 Return" ]]; do
							URL=$(shift; get_youtube 0 "$SUBSCRIBED_CHANNEL_SELECTED" "$TYPE_MEDIA_SEARCH_SELECTED")
							if [[ "$URL" != "󰌑 Return" ]]; then							
								shift; open_video "$URL"
							fi
						done
						;;
				esac
			done
		fi
	done
}

# Create a menu to find out what type of search the user wants to perform.
# Return the number of seelecction {0..4}.
main_menu()
{
	shift; menu "0:  News!\n1: 󰵀 Subscribed\n2:  Stored\n3:  Settings\n4:  Close" "--header 'Select an option'" 1
}

# Run the script until it stops.
while ! { [ "$MAIN_MENU" == "4" ] || [ "$MAIN_MENU" == "" ]; }; do
	MAIN_MENU=$(main_menu)
	case "$MAIN_MENU" in
		1) shift; subscribed_menu
		;;
	esac
done
