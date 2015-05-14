#!/bin/bash
# Spotify Conky Now Playing
# adapted from the script by Paul Williams 
if [ ! -f ~/.cache/spotify-nowplaying ]
    then
        ~/bin/conky.spotify.nowplaying.sh > ~/.cache/spotify-nowplaying
fi
if [ ! -f ~/.cache/spotify-paused ]
    then
        echo "0" > ~/.cache/spotify-paused
fi
song_length=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 Metadata | grep "length" | cut -b 15-)
artist=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 Metadata | grep "artist" | cut -b 15-)
title=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 Metadata | grep "title" | cut -b 14-)
album=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 Metadata | grep "album" | cut -b 14-)
# Is the same song playing?
if [ "$artist$title$album" != "$(cat ~/.cache/spotify-nowplaying)" ]
    then
        if [ ${#artist} -gt 38 ]
            then
                echo "1" > ~/.cache/spotifyArtistLength
            else
                rm ~/.cache/spotifyArtistLength
        fi
        if [ ${#title} -gt 38 ]
            then
                echo "1" > ~/.cache/spotifyTitleLength
            else
                rm ~/.cache/spotifyTitleLength
        fi
        if [ ${#album} -gt 38 ]
            then
                echo "1" > ~/.cache/spotifyAlbumLength
            else
                rm ~/.cache/spotifyAlbumLength
        fi
        wget -qO /tmp/coverart.jpg  $(wget -qO- -U "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:37.0) Gecko/20100101 Firefox/37.0" "https://play.spotify.com/track/$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 Metadata | egrep -o 'mpris:trackid: spotify:track:.{0,22}' | cut -b 30-)" | grep -o 'img id="cover-img".\{0,96\}' | cut -b 34-)
        echo "$artist$title$album" > ~/.cache/spotify-nowplaying
        echo $song_length > ~/.cache/spotify-nowplaying-length
        length=$(cat ~/.cache/spotify-nowplaying-length)
        secs=$(($length/1000000))
        printf ""%d:%02d"\n" $(($secs%3600/60)) $(($secs%60)) > ~/.cache/spotify-nowplaying-length-pretty
        date +%s > ~/.cache/spotify-nowplaying-starttime
        # reset paused time.
        echo "0" > ~/.cache/spotify-paused
fi
## is it playing, or paused?
status=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus)
if [ "$status" == "Paused" ] 
    then
        pt=$(cat ~/.cache/spotify-paused)
        pt=$(($pt+1))
        echo "$pt" > ~/.cache/spotify-paused
fi
pt=$(cat ~/.cache/spotify-paused)
 
# Work out time elapsed as a percentage of the total time.
timethen=$(cat ~/.cache/spotify-nowplaying-starttime)
timenow=$(date +%s)
# +1 to combat slight delay
elapsed=$((($timenow+1)-$timethen-$pt))
percent_complete=$(echo "$elapsed*1000000/$(cat ~/.cache/spotify-nowplaying-length)*100" | bc -l)
if [ ${percent_complete/.*} -gt 100 ]
    then
        percent_complete="0"
fi
echo -e "\${execbar echo '$percent_complete'}\n"
printf ""%d:%02d"\n" $(($elapsed%3600/60)) $(($elapsed%60)) > ~/.cache/spotify-nowplaying-elapsed-pretty
chmod 777 ~/.cache/spotify-*