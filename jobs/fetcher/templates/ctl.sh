#!/bin/bash -e

JOB_NAME=fetcher
BASE_DIR=/var/vcap
SYS_DIR=$BASE_DIR/sys
RUN_DIR=$SYS_DIR/run/$JOB_NAME
LOG_DIR=$SYS_DIR/log/$JOB_NAME
JOB_DIR=$BASE_DIR/jobs/$JOB_NAME
PIDFILE=$RUN_DIR/$JOB_NAME.pid

mkdir -p $RUN_DIR $LOG_DIR

case $1 in
  start)
    $JOB_DIR/bin/fetcher.sh \
      2>>$LOG_DIR/fetcher.stderr.log \
      1>>$LOG_DIR/fetcher.stdout.log \
      &
    echo $! > $PIDFILE
    ;;
  stop)
    kill $(cat $PIDFILE)
    ;;
  *)
    echo "Usage: ctl {start|stop}"
    ;;
esac
