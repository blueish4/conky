#!/bin/bash
current_time=$(echo "$(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Position)/1000000" | bc -l | grep -o ".\{0,3\}\.")
total_time=$(echo "$(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Metadata | grep length: | cut -b 15-)/1000000" | bc -l)
percent_complete=`echo "${current_time%?}/$total_time*100" | bc -l`

image_url=$(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Metadata | grep artUrl: | cut -b 22-)
echo -e "\${image $image_url -p 0,570 -s 250x250 -n}\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
echo "\${execbar echo $percent_complete}"