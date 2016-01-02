#!/bin/bash
cat qpid-web/web/ui/config.js.dist | sed "s/ADDR/$EXTIP/g" >qpid-web/web/ui/config.js
./QpidRestAPI.sh
