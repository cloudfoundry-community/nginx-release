#!/bin/bash -e

JOB_NAME=nginx
BASE_DIR=/var/vcap
SYS_DIR=$BASE_DIR/sys
RUN_DIR=$SYS_DIR/run/$JOB_NAME
LOG_DIR=$SYS_DIR/log/$JOB_NAME
JOB_DIR=$BASE_DIR/jobs/$JOB_NAME
CONFIG_DIR=$JOB_DIR/etc
CONFIG_FILE=$CONFIG_DIR/nginx.conf
PERSISTENT=$BASE_DIR/store
PIDFILE=$RUN_DIR/$JOB_NAME.pid

mkdir -p $RUN_DIR $LOG_DIR $CONFIG_DIR

<%- if_p('htpasswd_users') do |htpasswd_users| -%>
generate_htpasswd() {
<%- htpasswd_users.each do |entry| -%>
  echo "<%= entry['name'] %>:$(echo <%= entry['password'] %> | openssl passwd -apr1 -stdin)"
<%- end -%>
}
<%- end -%>

case $1 in
  start)
<%- if_p('htpasswd_users') do -%>
    generate_htpasswd > $CONFIG_DIR/htpasswd.conf
<%- end -%>
    $BASE_DIR/packages/nginx/sbin/$JOB_NAME -g "pid $PIDFILE;" -c $CONFIG_FILE
    ;;
  stop)
    kill $(cat $PIDFILE)
<%- if_p('htpasswd_users') do -%>
    rm -f $CONFIG_DIR/htpasswd.conf
<%- end -%>
    ;;
  *)
    echo "Usage: ctl {start|stop}"
    ;;
esac
