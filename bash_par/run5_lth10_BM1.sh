#!/bin/bash
#PBS -q default@meta-pbs.metacentrum.cz
#PBS -l select=1:ncpus=20:mem=39gb:scratch_local=40gb
#PBS -l walltime=50:00:00
#PBS -l matlab=1
#PBS -l matlab_Statistics_Toolbox=1
#PBS -l matlab_Signal_Toolbox=1
#PBS -l matlab_Distrib_Computing_Toolbox=1
#PBS -m abe
#PBS -M ozdogard@fel.cvut.cz
#PBS -N REV2par_BM46

# define a DATADIR variable: directory where the input files are taken from and where output will be copied to
DATADIR=/storage/praha5-elixir/home/ozdogard/jaes/codes/par_codes/
SAVEDIR=/storage/praha5-elixir/home/ozdogard/jaes/codes/par_codes/par_results/
ZIP_NAME=par_run_codes

module add matlab-9.14
module add clang

# test if scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" 

# copy input file to scratch directory
# if the copy operation fails, issue an error message and exit
cp "$DATADIR/$ZIP_NAME.zip" "$SCRATCHDIR" 

# move into the scratch directory
cd $SCRATCHDIR
unzip "$SCRATCHDIR/$ZIP_NAME.zip"
cd "$SCRATCHDIR/$ZIP_NAME/" 

matlab_script="run5_lth10_BM1"

matlab -nosplash -nodesktop -nodisplay < "$matlab_script.m" > "$matlab_script.txt"
# Capture the process ID (PID) of the last background command
matlab_pid=$!

# Wait for the MATLAB script to complete
wait $matlab_pid

outname="output5_lth10_BM1.mat"

# Check if the file exists
while [ ! -f "matlab.mat" ]; do
    sleep 600  # Adjust the sleep duration as needed
done

cp "matlab.mat" "$SAVEDIR/$outname"
cp "$matlab_script.txt" "$SAVEDIR/" 

# clean the SCRATCH directory
clean_scratch
