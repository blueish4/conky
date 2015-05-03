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
# Is the same song playing?
if [ "$(~/bin/conky.spotify.nowplaying.sh)" != "$(cat ~/.cache/spotify-nowplaying)" ]
    then
        ~/bin/conky.spotify.nowplaying.sh > ~/.cache/spotify-nowplaying
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
if [ "$status" == "Paused" ] || [ "$status" == "Stopped" ]
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
printf ""%d:%02d"\n" $(($elapsed%3600/60)) $(($elapsed%60)) > ~/.cache/spotify-nowplaying-elapsed-pretty
chmod 777 ~/.cache/spotify-*