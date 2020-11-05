#!/bin/bash
#SBATCH --job-name vasp
#SBATCH --output run.log
#SBATCH --ntasks=40
#SBATCH --mem=50G
#SBATCH --partition=batch
#SBATCH --qos=240c-1h_batch
#SBATCH --exclude=saliksik-cpu-[01,20,26]
#SBATCH --requeue
#SBATCH --verbose

## FORTRAN and C compilers
source /scratch1/$USER/intel/compilers_and_libraries_2019.0.117/linux/bin/compilervars.sh intel64
source /scratch1/$USER/intel/compilers_and_libraries_2019.0.117/linux/mkl/bin/mklvars.sh intel64
source /scratch1/$USER/intel/compilers_and_libraries_2019.0.117/linux/mpi/intel64/bin/mpivars.sh
export I_MPI_DEBUG=-5,pid,datetime,host,level
icc -v

echo "SLURM_JOBID    = " $SLURM_JOBID
echo "SLURM_JOB_NAME = " $SLURM_JOB_NAME
echo "SLURM_NTASKS   = " $SLURM_NTASKS
echo "SLURM_NODELIST = " $SLURM_NODELIST
echo "SLURM_NNODES   = " $SLURM_NNODES
echo "SLURM_MEM_PER_NODE   = " $SLURM_MEM_PER_NODE
echo "SLURM_TASKS_PER_NODE = " $SLURM_TASKS_PER_NODE
echo "SLURMTMPDIR    = " $SLURMTMPDIR
# export FI_LOG_LEVEL=debug
# export VT_CHECK_TRACING=on

######### VASP EXECUTABLES #######
vasp_path=/home/$USER/scratch/usr/vasp-6.1.1/bin
potdir=/home/$USER/POTCARS/PAW_PBE_54

### POTCAR
cat $potdir/Li/POTCAR $potdir/Ca_pv/POTCAR $potdir/Al/POTCAR $potdir/F/POTCAR > $PWD/POTCAR

### Change volume while lattice constant c is initialized 
rm $PWD/LiCaF_lattice.dat

for V in $(seq 200 1 240)
do

rm $PWD/WAVECAR

### set initial lattice parameters close to expt values and let it relax
c=9.6

echo "
=============================================================
V = $V  c = $c
============================================================="

## go to https://www.vasp.at/wiki/index.php/The_VASP_Manual for guide
cat > INCAR << end
SYSTEM = LiCaF-lattice
ENCUT = 450         ## cutoff energy (eV)
ISMEAR = -5         ## smearing method suitable for semiconductors
EDIFF = 1E-5        ## electronic relaxation is converged if energy difference is less than this
EDIFFG = -0.01      ## structural relaxation is converged if all forces are smaller than this. negative sign means force is calculated
NSW = 100           ## maximum number of iterations in relaxation
ISIF = 4            ## cell volume is fixed
IBRION = 2          ## algorithm for relaxation
PREC = Normal       ## precision: Normal, Accurate, ...
ALGO = Fast         ## algorithm: Normal, Fast, ...
NCORE = 4           ## number of cores to use
end

cat > KPOINTS << kend
k-points
0
M
9 9 9
0 0 0
kend

### POSCAR
python lattice_fixedV.py -V $V -c $c

### Run VASP
ulimit -s unlimited
mpirun  $vasp_path/vasp_std

### save to output file
python writeoutput.py  -o $PWD/LiCaF_lattice.dat

done

echo "
=============================================================
                      END OF RUN
============================================================="

### the relaxed coordinates is saved in CONTCAR. Save it and open in VESTA.