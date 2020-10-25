#!/bin/bash
#SBATCH --job-name vasp-2
#SBATCH --output run.log
#SBATCH --ntasks=80
#SBATCH --mem=80G
#SBATCH --partition=batch 
#SBATCH --qos=240c-1h_batch
#SBATCH --requeue
#SBATCH --verbose

source /scratch1/$USER/intel/compilers_and_libraries_2019.0.117/linux/bin/compilervars.sh intel64
source /scratch1/$USER/intel/compilers_and_libraries_2019.0.117/linux/mkl/bin/mklvars.sh intel64
source /scratch1/$USER/intel/compilers_and_libraries_2019.0.117/linux/mpi/intel64/bin/mpivars.sh
export I_MPI_DEBUG=-5,pid,datetime,host,level

module load anaconda/3-5.3.1
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

### Change lattice 
rm $PWD/LiCaF_lattice.dat

for a in $(seq 5.0 0.01 5.1)
do
for c in $(seq 9.50 0.01 9.70)
do 
rm WAVECAR

echo "
=============================================================
a = $a  c = $c
============================================================="

cat > INCAR << end
SYSTEM = LiCaF-lattice
ENCUT = 450 
ISMEAR = -5
EDIFF = 1E-5
PREC = normal
ALGO = FAST
NCORE = 4
end

cat > KPOINTS << kend
k-points
0
M
9 9 9
0 0 0
kend

### POSCAR
python lattice_hex.py -a $a -c $c

### Run VASP
ulimit -s unlimited
mpirun  $vasp_path/vasp_std

### save to output file
python VolE.py -a $a -c $c -o $PWD/LiCaF_lattice.dat
# E=`tail -1 $PWD/OSZICAR`
# echo $a $c $E >>  LiCaF_lattice.dat

done
done

echo "
=============================================================
                      END OF RUN
============================================================="
