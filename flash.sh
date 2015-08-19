#! /bin/bash

djtgcfg enum
djtgcfg init -d Atlys
djtgcfg prog -d Atlys -i 0 -f $1
