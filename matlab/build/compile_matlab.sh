#!/bin/bash
#
# Compile the matlab code so we can run it without a matlab license.

# Add Matlab to the path on the compilation machine
export MATLABROOT=~/MATLAB/R2023a
export PATH=${MATLABROOT}/bin:${PATH}

mcc -m -C -v ../src/entrypoint.m \
    -N \
    -p ${MATLABROOT}/toolbox/stats \
    -a ../src \
    -d ../bin

chmod go+rx ../bin/entrypoint
chmod go+rx ../bin/run_entrypoint.sh
