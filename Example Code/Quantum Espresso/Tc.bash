#!/bin/bash -l

#seperatly do the Tc calculation - this way you can vary mu without the need to redo the more expensive DOS and Phonon calculations

#this self prepares the needed files, you might want to manually change mu

# Batch script to run an MPI parallel job with the upgraded software
# stack under SGE with Intel MPI.

# 1. Force bash as the executing shell.
#$ -S /bin/bash

# 2. Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=1:00:00

# Budget setting
#$ -P Gold
#$ -A UKCP_ED_P

# 3. Request 1 gigabyte of RAM per process.
#$ -l mem=1G

# 5. Set the name of the job.
#$ -N QE_try

# 6. Select the MPI parallel environment and processes.
#$ -pe mpi 80

# 7. Set the working directory to the current directory.
#$ -cwd

module unload compilers mpi gcc-libs
module load gcc-libs/10.2.0
module load compilers/gnu/10.2.0
module load mpi/openmpi/4.0.5/gnu-10.2.0
module load fftw/3.3.9/gnu-10.2.0
module load quantum-espresso/7.3.1-cpu/gnu-10.2.0

mpirun --mca orte_base_help_aggregate 0
# Set the path here to where ever you keep your pseudopotentials.
export ESPRESSO_PSEUDO=$HOME/SSSP_1.3.0_PBE_efficiency

# Get estimate for T_c
# This can be done interactively

# 1. Prepare the lambda.in input file, which needs all q points and mu*:
# 1.1. emax (something more than highest phonon mode in THz), degauss, smearing method:
emax=`tail -1 FeH.dos | awk '{print $1*1.2*3/100}'`
echo "$emax  0.12  1" > lambda.in
# 1.2. q-point mesh:
# Add number of q points
nqibz=`grep q-points\) FeH.elph.out | sed "s/q-points/ /g" | awk '{print $2}'`
echo $nqibz >> lambda.in
# Add q points and weights
grep -A1 -e 'Computing dynamical matrix for' -e 'star' FeH.elph.out | grep q | grep = | awk 'BEGIN {lstar=1} {if($1=="q") {printf "%10.6f %10.6f %10.6f ",$4,$5,$6}; if(($1=="Number")&&(lstar==1)) {printf "%5.2f\n",$8;lstar=0} else {lstar=1} }' >> lambda.in
# 1.3. Add names of elph output files
for nq in $(seq 1 $nqibz); do
  echo "elph_dir/elph.inp_lambda.$nq" >> lambda.in
done
# 1.4. Add mu* parameter:
echo 0.1 >> lambda.in

# 2. Run lambda.x to obtain mode-averaged el-ph coupling
#    and estimates for T_c
#lambda.x -in lambda.in > lambda.out

lambda.x < lambda.in > lambda.out
