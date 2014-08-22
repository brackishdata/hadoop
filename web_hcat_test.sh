#!/bin/bash
curl -i -d user.name=adam \
        -d input=/user/adam/test.dat \
       -d output=/user/adam/mycounts \
       -d mapper=/bin/cat \
       -d reducer="/usr/bin/wc -w" \
       'http://HOSTNAME:50111/templeton/v1/mapreduce/streaming'
