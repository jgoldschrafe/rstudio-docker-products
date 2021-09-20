#!/bin/bash
set -xe

RSW_TIMEOUT=${RSW_TIMEOUT:-15}

# start rstudio-server
echo "--> Starting RStudio Workbench"
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf > /tmp/startup.log 2>&1 &

echo "--> Waiting for workbench to startup... with RSW_TIMEOUT: $RSW_TIMEOUT"
wait-for-it.sh localhost:8787 -t $RSW_TIMEOUT
echo "--> Startup complete"

GOSS_FILE=${GOSS_FILE:-/tmp/goss.yaml}
GOSS_VARS=${GOSS_VARS:-/tmp/goss_vars.yaml}
GOSS_VERSION=${GOSS_VERSION:-0.3.16}
GOSS_MAX_CONCURRENT=${GOSS_MAX_CONCURRENT:-50}

# default to empty var file (since vars are not necessary)
if [ ! -f "$GOSS_VARS" ]; then
  touch $GOSS_VARS
fi

# install goss to tmp location and make executable
curl -sL https://github.com/aelsabbahy/goss/releases/download/v$GOSS_VERSION/goss-linux-amd64 -o /tmp/goss \
  && chmod +x /tmp/goss \
  && GOSS=/tmp/goss

GOSS_FILE=$GOSS_FILE GOSS_VARS=$GOSS_VARS $GOSS v --format documentation --max-concurrent $GOSS_MAX_CONCURRENT
