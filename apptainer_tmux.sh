#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <container_image> [host_name]"
    exit 1
fi
HOST_NAME="${2:-ub24}"

apptainer exec --no-pid --nv --hostname "$HOST_NAME" \
    -B /eva_data0:/eva_data0 \
    -B /eva_data1:/eva_data1 \
    -B /eva_data2:/eva_data2 \
    -B /eva_data3:/eva_data3 \
    -B /eva_data4:/eva_data4 \
    -B /eva_data5:/eva_data5 \
    -B /eva_data6:/eva_data6 \
    -B /eva_data7:/eva_data7 \
    "$1" tmux