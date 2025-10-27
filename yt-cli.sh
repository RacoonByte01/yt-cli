#!/bin/bash

menu(){
	#echo -en $2
	echo -en "$1" | sh -c "fzf $2" | awk -F: '{printf $1}'
}

main_menu()
{
	shift; menu '0: News!\n1: Subscribed\n2: Stored\n3: Settings\n4: Close' "--header 'Select an option' --preview='figlet -f ANSI\ Shadow Hi again :3'"
}

main_menu
