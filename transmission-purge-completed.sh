#!/bin/bash

TORRENTLIST=`/storage/.kodi/addons/service.transmission/bin/transmission-remote --list | sed -e '1d;$d;s/^ *//;s/*//' | cut -s -d ' ' -f 1`

/storage/.kodi/addons/service.transmission/bin/transmission-remote --list

for TORRENTID in $TORRENTLIST
do
    DL_NAME=`/storage/.kodi/addons/service.transmission/bin/transmission-remote --torrent $TORRENTID --info | grep "Name: " | cut -s -d ' ' -f 4`
    DL_COMPLETED=`/storage/.kodi/addons/service.transmission/bin/transmission-remote --torrent $TORRENTID --info | grep "Percent Done: 100"`
    DL_MOVED=`/storage/.kodi/addons/service.transmission/bin/transmission-remote --torrent $TORRENTID --info | grep "Error: No data found!"`
    
    if [ "$DL_COMPLETED" != "" ]; then
        echo "Torrent $DL_NAME is completed. Removing torrent from list..."
        
        /storage/.kodi/addons/service.transmission/bin/transmission-remote --torrent $TORRENTID --remove-and-delete
        ( sleep 1m ; \
            rm -rf "/media/sda-usb-Mass_Storage_Dev/downloads/$DL_NAME"
            curl --data-binary '{ "jsonrpc": "2.0", "method": "VideoLibrary.Scan", "id": "mybash"}' -H 'content-type: application/json;' http://localhost:8080/
        ) &
    elif [ "$DL_MOVED" != "" ]; then
        echo "Torrent $DL_NAME is broken. Restarting..."
        /storage/.kodi/addons/service.transmission/bin/transmission-remote --torrent $TORRENTID --verify --start
    else
        echo "Torrent $DL_NAME is not completed. Ignoring..."
    fi
done
