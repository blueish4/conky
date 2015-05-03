#!/bin/bash
 
echo "  Artist:" `qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 Metadata | grep "artist" | cut -b 15-` 
echo "  Title: " `qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 Metadata | grep "title" | cut -b 14-`
echo "  Album: " `qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 Metadata | grep "album" | cut -b 14-`