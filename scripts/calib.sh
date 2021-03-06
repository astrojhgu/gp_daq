#!/bin/sh

if [ $# != 2 ]
then
    echo "Usage:" $0 "<Att1> <Att2>"
    exit
fi

SELF_PATH=`realpath $0`
SELF_DIR=`dirname $SELF_PATH`
PROG_DIR=$SELF_DIR/../target/release/
CFG_DIR=${SELF_DIR}/../cfgs

if [ "x$DATADIR" = x ]
then
    echo "set DATADIR first"
    exit
fi


# Configuration
#BOARDID=$1

if [ -f $DATADIR/last_run.txt ]
then
 :
 else
  echo 0 > $DATADIR/last_run.txt
fi
NRUN=$(<$DATADIR/last_run.txt)
NRUN=$(($NRUN+1))
echo "NRUN=" $NRUN

if [ "$1" -gt "127" ] || [ "$2" -gt "127" ]
then
  echo "Error: 127 is the max value allowed for attenuation factor. Aborting."
  exit 0
fi
  
awk '/att1/{$2='$1'}1;' $CFG_DIR/calibgen.yaml > $CFG_DIR/temp.yaml
awk '/att2/{$2='$2'}1;'  $CFG_DIR/temp.yaml > $CFG_DIR/calib$NRUN.yaml

# Clean
tmux kill-window -t "calib" 
 

# Log run id
rm $DATADIR/last_run.txt
echo $NRUN >> $DATADIR/last_run.txt
cp ${CFG_DIR}/calib$NRUN.yaml  $DATADIR/C$NRUN.yaml

# Execute run
SLC_FILE=$DATADIR/S${NRUN}.yaml
DATA_FILE=$DATADIR/C${NRUN}.data
cat boardsIn.txt | while read BOARDID
do
  echo "Now doing board " $BOARDID
  $SELF_DIR/run.sh  ${BOARDID} $CFG_DIR/calib$NRUN.yaml 1235 $SLC_FILE 1236 $DATA_FILE "calib" 500
done

# Clean
echo "Now killing tmux window calib." 
tmux kill-window -t "calib"
