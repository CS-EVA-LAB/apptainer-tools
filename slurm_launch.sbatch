#!/bin/bash

#SBATCH --account=YOUR_BILLING_ACCOUNT         # Billing account
#SBATCH --job-name=default                     # Job name
#SBATCH --output=slurm_logs/slurm_%j.out       # Standard output and error log (%j expands to jobID)
#SBATCH --error=slurm_logs/slurm_%j.err        # Standard error log
#SBATCH --nodes=1                              # Number of nodes (e.g., 2) - ADJUST AS NEEDED
#SBATCH --ntasks-per-node=1                    # Number of tasks (master processes) per node - torchrun handles worker processes
#SBATCH --cpus-per-task=12                     # CPU cores per task (e.g., 2-8 per GPU) - ADJUST AS NEEDED
#SBATCH --gpus-per-node=1                      # Number of GPUs per node (e.g., 8) - ADJUST AS NEEDED
#SBATCH --mem=256G                             # Memory per node (e.g., 64G, 128G) - ADJUST AS NEEDED
#SBATCH --time=48:00:00                        # Time limit hrs:min:sec (e.g., 24:00:00) - ADJUST AS NEEDED
#SBATCH --partition=normal2                    # Partition name - REPLACE WITH YOUR ACTUAL PARTITION
#SBATCH --mail-type=ALL                        # Setup email notifications for job start, end, and failure
#SBATCH --mail-user=YOUR_EMAIL_HERE            # Email address for notifications

# Ensure the output directory for logs exists
mkdir -p slurm_logs
export PATH="$HOME/.local/share/apptainer/bin/:$PATH" # Ensure local bin is in PATH
export MODULEPATH="$HOME/modulefiles/:$MODULEPATH" # Added custom modulefiles path. Adjust this path if necessary

# Load necessary modules for your environment (examples, adjust as needed)
# module purge
# module load cuda/11.8
# module load anaconda3/2023.09

# Activate conda environment if you don't want to use provided conda environment
. $HOME/miniconda3/etc/profile.d/conda.sh
conda activate py12

# update job name dynamically based on a random cool name generator (e.g. python coolname package) for 
# better tracking in job queues. You can replace this with any naming scheme you prefer.
# NOTE: Sometimes the job name may not update in the queue (e.g., on NCHC nano5)
export SLURM_JOB_NAME=$(coolname 2)
scontrol update JobId=$SLURM_JOB_ID JobName="$SLURM_JOB_NAME"

# print SLURM job information for debugging and tracking
echo "---------------------------------------------------------------------"
echo "SLURM JOB INFO:"
echo "JOB ID: $SLURM_JOB_ID"
echo "JOB NAME: $SLURM_JOB_NAME"
echo "NODELIST: $SLURM_JOB_NODELIST"
echo "NNODES: $SLURM_NNODES"
echo "NTASKS: $SLURM_NTASKS"
echo "TASKS_PER_NODE: $SLURM_TASKS_PER_NODE"
echo "GPUS_ON_NODE: $SLURM_GPUS_ON_NODE" # May be set if --gpus or --gpus-per-node is used
echo "CPUS_ON_NODE: $SLURM_CPUS_ON_NODE"
echo "REQUESTED GRES: $SLURM_JOB_GRES"
echo "SUBMIT_DIR: $SLURM_SUBMIT_DIR"
echo "---------------------------------------------------------------------"


# Master address and port for torchrun
# The first node in the job's allocation will be the master.
export MASTER_ADDR=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | head -n 1)
# export MASTER_PORT=31313  # You can choose any free port (ensure it's not used by other jobs on the node)
export OMP_NUM_THREADS=1

# Set project root, assuming the script is in the project root and submitted from there
PROJECT_ROOT="$SLURM_SUBMIT_DIR" # SLURM_SUBMIT_DIR is the directory from which sbatch was invoked

echo "---------------------------------------------------------------------"
echo "TORCHRUN CONFIGURATION:"
echo "MASTER_ADDR: $MASTER_ADDR"
echo "MASTER_PORT: $MASTER_PORT"
echo "NNODES: $SLURM_NNODES"
printf "CMD_ARGS: ${CMD_ARGS[*]}"
echo "---------------------------------------------------------------------"

# print GPU information
nvidia-smi

# Launch DDP training using srun to execute torchrun on the primary task.
# torchrun will then manage processes across all allocated nodes and GPUs.
# NOTE: Adjust the path to your container image and the torchrun command as needed.
srun --kill-on-bad-exit=1 apptainer exec --env PATH="$PATH" --nv \
          -B /work:/work -B /etc/pki/:/etc/pki/ -B /etc/ssl/:/etc/ssl/ \
          "YOUR_CONTAINER_LOCATION (.sif file or mutable folder)" \
          torchrun.bash # Command to run inside apptainer (here we use a custom
                        # wrapper script torchrun.bash that sets up the environment and runs torchrun)

EXIT_CODE=$?

echo "---------------------------------------------------------------------"
echo "Training finished with exit code $EXIT_CODE."
echo "Job output/error logs are in slurm_logs/ directory with Job ID $SLURM_JOB_ID."
echo "---------------------------------------------------------------------"

exit $EXIT_CODE
