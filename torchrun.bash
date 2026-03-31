#!/bin/bash

# initialize the conda environment on each job/node and then launch the training script with torchrun.
. $HOME/miniconda3/etc/profile.d/conda.sh
CONDA_ENV_NAME=${CONDA_ENV_NAME:-py12}
conda activate $CONDA_ENV_NAME
export 1>&2


RUN_NAME=${SLURM_JOB_NAME:-default}
NNODES=${SLURM_NNODES:-1}
NPROC_PER_NODE=${SLURM_GPUS_ON_NODE:-1}
JOB_ID=${SLURM_JOB_ID:-$(cat /dev/urandom | tr -dc '0-9' | fold -w 6 | head -n 1)}
export MASTER_ADDR=${MASTER_ADDR:-localhost}
export MASTER_PORT=${MASTER_PORT:-$(($JOB_ID % 61510 + 4024))}

# export TORCH_DISTRIBUTED_DEBUG=DETAIL # enable PyTorch DDP debugging mode as needed

nvidia-smi

torchrun \
  --nnodes=$NNODES \
  --nproc_per_node=$NPROC_PER_NODE \
  --rdzv-id=$JOB_ID \
  --rdzv-backend=c10d \
  --rdzv-endpoint=$MASTER_ADDR:$MASTER_PORT \
  YOUR_PYTHON_SCRIPT_AND_ARGS_STARTS_AFTER_HERE

# Below is an example of how to use torchrun to launch a distributed training job with specific configurations. 
# You can replace the placeholders with your actual training script and arguments.
# ----------------------------------------------------------------------------------
# torchrun \
#   --nnodes=$NNODES \
#   --nproc_per_node=$NPROC_PER_NODE \
#   --rdzv-id=$JOB_ID \
#   --rdzv-backend=c10d \
#   --rdzv-endpoint=$MASTER_ADDR:$MASTER_PORT  \
#   -m run train \
#   --default_config pilot/configs/_default_tc.yaml \
#   --config pilot/configs/ssv2/dino_tc_DINO_decoder_32f.yaml \
#   run_name=$RUN_NAME \
#   dataset.root=$HOME/workspace/ssv2/ \
#   note="dino_tc_action on 32f ssv2 with 2L ActionDecoderDINOBlocks" \
#   tags=[] \
#   training.batch_size=32 eval.batch_size=64 \
#   num_workers=32 \
#   --wandb