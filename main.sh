#!/bin/bash

nginx -g 'daemon off;' & 
/usr/local/bin/stress --verbose $@