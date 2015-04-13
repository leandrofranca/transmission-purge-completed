#!/bin/sh

TORRENTLIST=`transmission-remote --auth=transmission:transmission --list | sed -e '1d;$d;s/^ *//;s/*//' | cut --only-delimited --delimiter=' ' --fields=1`
PATH_LOG=~

transmission-remote --auth=transmission:transmission --list

for TORRENTID in $TORRENTLIST
do

echo "## Operations on torrent ID $TORRENTID starting ##"

DL_COMPLETED=`transmission-remote --auth=transmission:transmission -t $TORRENTID --info | grep "Percent Done: 100%"`
DL_MOVED=`transmission-remote --auth=transmission:transmission -t $TORRENTID --info | grep "Error: No data found!"`

if [ "$DL_COMPLETED" != "" ] || [ "$DL_MOVED" != "" ]; then
  echo "Torrent #$TORRENTID is completed."
  echo "Removing torrent from list."

  DL_NAME=`transmission-remote --auth=transmission:transmission -t $TORRENTID --info | grep "Name:"`
  DL_LAST_ACTIVITY=`transmission-remote --auth=transmission:transmission -t $TORRENTID --info | grep "Latest activity:"`
  DL_PUSH="$DL_NAME || $DL_LAST_ACTIVITY"

  echo $DL_PUSH >> $PATH_LOG/transmission-purge-completed.log

  transmission-remote --auth=transmission:transmission --torrent $TORRENTID --remove
else
  echo "Torrent #$TORRENTID is not completed. Ignoring."
fi
  echo "## Operations on torrent ID $TORRENTID completed ##"
done
