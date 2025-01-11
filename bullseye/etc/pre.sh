#!/bin/bash

# PRE HOOK
#  Make your customisation here
echo "pre-hook: attempting to configure portPolicy: passthrough"

# TODO: check if the returned gameserver spec contains portPolity setting. If so, only attempt to set CS2_PORT if port policy is set to passthrough.

PASSTHROUGH_PORT=$(curl -s -H "Content-Type: application/json" -X GET http://localhost:${AGONES_SDK_HTTP_PORT}/gameserver | jq '.status.ports[] | select(.name == "default-tcp").port')

if [ ! -z $PASSTHROUGH_PORT ]; then
  echo "pre=hook: setting CS2_PORT to ${PASSTHROUGH_PORT}"
  CS2_PORT=$PASSTHROUGH_PORT
fi;

