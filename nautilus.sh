#!/bin/bash
# Nautilus file manager needed.
# Opens file manager with interesting folders.
# Also needed wmctrl and xdotool

FOLDERLIST="dist/org/languagetool/rules/es
languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool/rules/es
dict"
	
if [ "$(wmctrl -xl | grep "nautilus\.Nautilus")" == "" ]; then
    nautilus &
    sleep 2
fi 
    #Save old clipboard value
    oldclip="$(xclip -o -sel clip)"
for folder in $FOLDERLIST
	{
	echo $folder	
    echo -n $folder | xclip -i -sel clip
    wmctrl -xF -R nautilus.Nautilus && xdotool key --delay 230 ctrl+t ctrl+l ctrl+v Return
    xclip -verbose -o -sel clip
    sleep 0.5
}
    #Restore old clipboard value
    echo -n "$oldclip" | xclip -i -sel clip

