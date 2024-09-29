#!/bin/bash -l
# Batch script to run an MPI parallel job with the upgraded software
# stack under SGE with Intel MPI.

# 1. Force bash as the executing shell.
#$ -S /bin/bash

# 2. Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=24:00:00

# Budget setting
#$ -P Gold
#$ -A UKCP_ED_P

# 3. Request 1 gigabyte of RAM per process.
#$ -l mem=1G

# 5. Set the name of the job.
#$ -N CoH-3m-Wang

# 6. Select the MPI parallel environment and processes.
#$ -pe mpi 80

# 7. Set the working directory to the current directory.
#$ -cwd

# 8. Run our MPI job.  GERun is a wrapper that launches MPI jobs on our clusters
# Adjust VASP location to your local setup
VASPBIN=$HOME/vasp_std
oneapi/mkl/latest/lib/intel64:$LD_LIBRARY_PATH

oldpress=0
for press in 0.001 $(seq 50 50 450) $(seq 500 100 3000); do

mkdir -p $press
cd $press

# set up VASP inputs:
sed "/PSTRESS/s/.*/PSTRESS = $press/g" ../INCAR > INCAR
cp ../KPOINTS .
cat ../POTCAR > POTCAR

# set up crystal structure:
if [ -s CONTCAR ]; then
  cp CONTCAR POSCAR
else if [ -s ../$oldpress/CONTCAR ]; then
  cp ../$oldpress/CONTCAR POSCAR
else
  cp ../CoH-Fm-3m-Wang2018-p-1atm.vasp POSCAR
fi
fi

# Run the program

rm out-press-$press
for iter in $(seq 1 5); do

gerun $VASPBIN >> out-press-$press
# For CP-lab/studentrun, use this command instead:
#mpirun -np 4 $VASPBIN >> out-press-$press

# An option to catch symmetry failures in the VASP run
grep 'VERY BAD' out-press-$press
if [ $? == "0" ]; then

  echo "ISYM = 0" >> INCAR
  echo "NEED TO SET ISYM = 0" >> out-press-$press
  sed -i "/VERY BAD/d" out-press-$press

  gerun $VASPBIN >> out-press-$press
fi

cp CONTCAR CONTCAR-$iter
cp OUTCAR OUTCAR-$iter
cp CONTCAR POSCAR

done
cd ..
oldpress=$press

done