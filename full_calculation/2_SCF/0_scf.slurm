#!/bin/bash
#SBATCH --job-name LiCaF_scf
#SBATCH --output 1_run.log
#SBATCH --ntasks=80
#SBATCH --mem=80G
#SBATCH --partition=batch 
#SBATCH --qos=240c-1h_batch
#SBATCH --exclude=saliksik-cpu-[01,20]
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
dirpath="./.."
#/scratch1/$USER/codes/vasp_tutorial/LiCaF

### POTCAR
cat $potdir/Li/POTCAR $potdir/Ca_sv/POTCAR $potdir/Al/POTCAR $potdir/F/POTCAR > $PWD/POTCAR

### POSCAR
cp $dirpath/1_relax/CONTCAR $dirpath/2_SCF/POSCAR # copy relaxed coordinates then rename to POSCAR

## go to https://www.vasp.at/wiki/index.php/The_VASP_Manual for guide
rm $PWD/WAVECAR
cat > INCAR << end
#===== control parameters =====#
SYSTEM = LiCaF-SCF
ISTART = 0          ## start from scratch
PREC = Accurate     ## precision: Normal, Accurate, ...
ALGO = Fast         ## algorithm: Normal, Fast, ...
NCORE = 4           ## number of cores to use
LWAVE = .FALSE.     ## don't write WAVECAR file
LCHARG = .TRUE.     ## write charge density file CHGCAR

#==== electronic optimization ====#
ENCUT = 520         ## cutoff energy (eV); 130% OF ENMAX in POTCAR file
ISMEAR = -5         ## tetrahedron smearing method suitable for semiconductors

#==== ionic relaxation ====#
IBRION = -1         ## atomic positions are not moved
NSW = 0             ## maximum number of iterations in relaxation
EDIFF = 1E-6        ## electronic relaxation is converged if energy difference is less than this
EDIFFG = -0.005     ## structural relaxation is converged if all forces are smaller than this. negative sign means force is calculated
end

cat > KPOINTS << kend
k-points
0
Monkhorst Pack
9 9 9
0 0 0
kend

### Run VASP
ulimit -s unlimited
mpirun  $vasp_path/vasp_std

### save to output file
# python writeoutput.py  -o $PWD/LiCaF_lattice.dat

echo "
=============================================================
                      END OF RUN
============================================================="

