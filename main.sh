#!/bin/bash

/usr/local/bin/stress --verbose "$@" &
nginx -g 'daemon off;'
