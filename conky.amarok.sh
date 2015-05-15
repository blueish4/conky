#!/bin/bash
current_time=$(echo "$(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Position)/1000000" | bc -l | grep -o ".\{0,3\}\.")
total_time=$(echo "$(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Metadata | grep length: | cut -b 15-)/1000000" | bc -l | grep -o ".\{0,3\}\.")
artist=$(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Metadata | grep :artist: | cut -b 15-)
title=$(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Metadata | grep title: | cut -b 14-)
album=$(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Metadata | grep :album: | cut -b 14-)
if [ ! -f /tmp/amarok-nowplaying ]
    then
        echo "$artist$title$album" > /tmp/amarok-nowplaying
fi
#Is the same song playing?
if [ "$artist$title$album" != "$(cat /tmp/amarok-nowplaying)" ]
    then
        #send whether the parts require marquee text
        if [ ${#artist} -gt 38 ]
            then
                echo "1" > /tmp/amarokArtistLength
            else
                rm /tmp/amarokArtistLength
        fi
        if [ ${#title} -gt 38 ]
            then
                echo "1" > /tmp/amarokTitleLength
            else
                rm /tmp/amarokTitleLength
        fi
        if [ ${#album} -gt 38 ]
            then
                echo "1" > /tmp/amarokAlbumLength
            else
                rm /tmp/amarokAlbumLength
        fi
        cp $(qdbus org.mpris.MediaPlayer2.amarok /org/mpris/MediaPlayer2 Metadata | grep artUrl: | cut -b 22-) /tmp/amarokcover.jpg
        echo "$artist$title$album" > /tmp/amarok-nowplaying
fi

echo "\${execbar echo $(echo "${current_time%?}/${total_time%?}*100" | bc -l)}"
echo $(date -d@${current_time%?} -u +%M:%S)/$(date -d@${total_time%?} -u +%M:%S)