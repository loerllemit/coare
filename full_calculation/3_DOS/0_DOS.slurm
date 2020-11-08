#!/bin/bash
#SBATCH --job-name LiCaF_DOS
#SBATCH --output 1_run.log
#SBATCH --ntasks=80
#SBATCH --mem=150G
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
dirpath=dirpath="./.."

### POTCAR
cat $potdir/Li/POTCAR $potdir/Ca_sv/POTCAR $potdir/Al/POTCAR $potdir/F/POTCAR > $PWD/POTCAR

### POSCAR
cp $dirpath/1_relax/CONTCAR $dirpath/3_DOS/POSCAR # copy relaxed coordinates then rename to POSCAR

### CHGCAR
cp $dirpath/2_SCF/CHGCAR    $dirpath/3_DOS/CHGCAR 

## go to https://www.vasp.at/wiki/index.php/The_VASP_Manual for guide
rm $PWD/WAVECAR
cat > INCAR << end
#===== control parameters =====#
SYSTEM = LiCaF-DOS
ISTART = 1          ## start from WAVECAR if present
ICHARG = 11         ## charge density read from CHGCAR
PREC = Accurate     ## precision: Normal, Accurate, ...
ALGO = Normal       ## algorithm: Normal, Fast, ...
KPAR = 10            ## number of cores to use
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

#==== DOS parameters ====#
LORBIT = 11         ## DOSCAR and partial dos PROCAR are written
NEDOS = 2500        ## number of data points to sample
#EMIN = 
#EMAX =
NBANDS = 80         ## number of bands as calculated in OUTCAR of previous runs
end

cat > KPOINTS << kend
k-points
0
Gamma
20 20 20            ## increase the number if doing DOS calculation
0 0 0
kend

### Run VASP
ulimit -s unlimited
mpirun  $vasp_path/vasp_std

echo "
=============================================================
                      END OF RUN
============================================================="

