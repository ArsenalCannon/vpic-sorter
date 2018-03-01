#!/bin/bash

# Modify these parameters
export filepath=/net/scratch3/xiaocanli/reconnection/open3d-full/tracer_test/
export particle=electron
tstep_min=0
tstep_max=13
tinterval=13
is_recreate=1 # recreate a file?
nsteps=1
reduced_tracer=1
mpi_size=36
ux_index=6
q_index=13       # particle tag index in the HDF5 file
energy_index=14  # >= number of datasets in the HDF5 file
echo "Maximum time step:" $tstep_max
echo "Time interval:" $tinterval

tstep=13
fpath=$filepath/T.$tstep
input_file=$fpath/${particle}_tracer_reduced_sorted.h5p
output_file=$fpath/${particle}_tracer_energy_sorted.h5p
meta_file=$fpath/grid_metadata_${particle}_tracer_reduced.h5p

cd ../

# sort by particle energy
rm $output_file
srun -n $mpi_size \
./h5group-sorter -f $input_file \
                 -o $output_file \
                 -g /Step#$tstep \
                 -m $meta_file \
                 -k $energy_index \
                 -a attribute \
                 -u $ux_index \
                 --tmin=$tstep_min \
                 --tmax=$tstep_max \
                 --tinterval=$tinterval \
                 --filepath=$filepath \
                 --species=${particle} \
                 --is_recreate=$is_recreate \
                 --nsteps=$nsteps \
                 --reduced_tracer=$reduced_tracer

# sort by particle tag
output_file=$fpath/${particle}_tracer_qtag_sorted.h5p
srun -n $mpi_size \
./h5group-sorter -f $input_file \
                 -o $output_file \
                 -g /Step#$tstep \
                 -m $meta_file \
                 -k $q_index \
                 -a attribute \
                 --tmin=$tstep_min \
                 --tmax=$tstep_max \
                 --tinterval=$tinterval \
                 --filepath=$filepath \
                 --species=${particle} -u 6 \
                 -p -r --filename_traj=data/${particle}s_3.h5p \
                 --nptl_traj=1000 \
                 --ratio_emax=1 \
                 --is_recreate=$is_recreate \
                 --nsteps=$nsteps \
                 --reduced_tracer=$reduced_tracer

# -q -w -r --filename_traj=data/${particle}s_3.h5p \

cd config
