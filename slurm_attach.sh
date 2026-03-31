#!/bin/bash
# This script is used to attach to a running SLURM job.

# Usage: ./slurm_attach.sh <job_id>
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <job_id>"
    exit 1
fi
srun --pty --overlap --jobid $1 bash