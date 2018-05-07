#!/bin/sh -

STORED_STATE_PATH=/root/storedstate
OUTPUT_PATH=$STORED_STATE_PATH"/output"

if [ ! -e $OUTPUT_PATH ]; then
    mkdir $OUTPUT_PATH
    cp ../.config $OUTPUT_PATH"/.config"
fi

if [ $# -eq 0 ]; then
    /bin/bash
else
    make $@
fi
