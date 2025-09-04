#!/usr/bin/env bash

###########################
# This script runs AlphaFold3 PPI predictions for the defined subset.
# It uses an array job to process 2 PPI ids at a time until the 383 are done.
#
# The SLURM options request GPUs, set runtime limits, and handle job logging.
# For each job, it:
# - Loads the AlphaFold3 environment and sets paths
# - Picks the next PPI ID and JSON input file from the input
# - Runs the AlphaFold3 scoring command
# - Logs how long it took and checks for succes/failure based on 
# the presence of a AlphaFold3 summary_confidences.json ouput for the PPI ID
#
###########################

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --gres=gpu
#SBATCH --time=05:00:00
#SBATCH --partition=aa100
#SBATCH --qos=normal
#SBATCH --output=logs/scoring_ppi-%j.out
#SBATCH --error=logs/scoring_ppi-%j.err
#SBATCH --array=1-383%2

### SET UP ENVIRONMENT MASTER ###
# Set working directory
cd /projects/$USER/ppi_network

# Create master log to capture success of each job
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
MASTER_LOG="$PWD/scripts/logs/run_master-remaining.log"

echo "Master log file: $MASTER_LOG"

### SET UP ENVIROMENT FOR GIVEN JOB ###
# Capture start of given job
JOB_START=$(date +%s)

# Set path to parameters
export AF3_MODEL_PARAMETERS_DIR=$PWD/data/alphafold3/parameters
# Set path to AF3 directory
export AF3_DIR=$PWD/results/alphafold3
# Set path to input directory
export AF3_INPUT_DIR=$AF3_DIR/json_inputs
# Set path to input ppi id list
export AF3_INPUT_LIST=$AF3_DIR/scoring_ppi.tab
# Set path to output
export AF3_OUTPUT_DIR=$AF3_DIR/raw_outputs

# Get the line from the .tab file corresponding to this task ID (skipping header)
LINE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$AF3_INPUT_LIST")

# Extract PPI ID (col 1) and JSON path (col 4)
PPI_ID=$(echo "$LINE" | awk -F'\t' '{print $1}')
# Create variable for given JSON input
AF3_INPUT_FILE=$(echo "$LINE" | awk -F'\t' '{print $4}')

echo "[$(date)] START Job ${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID} for $PPI_ID (input: $AF3_INPUT_FILE)" >> "$MASTER_LOG"

# Load Alphafold 3 module
module purge
module load alphafold/3.0.0

# Set temp directory paths
export TMPDIR=/scratch/alpine/$USER/tmp-alphafold
mkdir -pv $TMPDIR
export TEMP=$TMPDIR
export TMP_DIR=$TMPDIR
export TEMP_DIR=$TMPDIR
export TEMPDIR=$TMPDIR

### BEGIN ALPHAFOLD SCORING ###
run_alphafold --json_path=$AF3_INPUT_FILE --output_dir=$AF3_OUTPUT_DIR --model_dir=$AF3_MODEL_PARAMETERS_DIR

# Capture end time of job
JOB_END=$(date +%s)
# Calculate elapsed time of job by subtracting end and start
JOB_ELAPSED=$((JOB_END - JOB_START))

# Format elapsed time into minutes and seconds
JOB_ELAPSED_FMT=$(printf "%02dm%02ds" $((JOB_ELAPSED/60)) $((JOB_ELAPSED%60)))

### CHECK FOR JOB SUCCESS
# Find the summary confidences file ignoring case of ppi id
PPI_OUTPUT_DIR=$(find "$AF3_OUTPUT_DIR" -maxdepth 1 -type d -iname "$PPI_ID" | head -n 1)

# Construct the expected file path and check for it
if [ -n "$PPI_OUTPUT_DIR" ]; then
    OUTPUT_FILE=$(find "$PPI_OUTPUT_DIR" -maxdepth 1 -type f -iname "${PPI_ID}_summary_confidences.json" | head -n 1)
    if [ -n "$OUTPUT_FILE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS for $PPI_ID (Job ${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}) — Elapsed: $JOB_ELAPSED_FMT" >> "$MASTER_LOG"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILURE for $PPI_ID — File missing inside matching dir: ${PPI_ID}_summary_confidences.json" >> "$MASTER_LOG"
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILURE for $PPI_ID — Output subdirectory not found under $AF3_OUTPUT_DIR" >> "$MASTER_LOG"
fi
