#!/bin/sh

TORRENTLIST=`transmission-remote --list | sed -e '1d;$d;s/^ *//;s/*//' | cut -s -d ' ' -f 1`

transmission-remote --list

for TORRENTID in $TORRENTLIST
do
    echo "## Operations on torrent ID $TORRENTID starting ##"
    
    DL_COMPLETED=`transmission-remote --torrent $TORRENTID --info | grep "Percent Done: 100"`
    DL_MOVED=`transmission-remote --torrent $TORRENTID --info | grep "Error: No data found!"`
    
    if [ "$DL_COMPLETED" != "" ]; then
        echo "Torrent #$TORRENTID is completed."
        echo "Removing torrent from list."
        
        transmission-remote --torrent $TORRENTID --remove-and-delete
    elif [ "$DL_MOVED" != "" ]; then
        echo "Torrent #$TORRENTID is broken. Restarting..."
        transmission-remote --torrent $TORRENTID --verify --start
    else
        echo "Torrent #$TORRENTID is not completed. Ignoring."
    fi
    echo "## Operations on torrent ID $TORRENTID completed ##"
done
