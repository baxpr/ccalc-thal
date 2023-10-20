#!/bin/sh
#
# Compile the matlab code so we can run it without a matlab license.

# Add Matlab to the path on the compilation machine
export PATH=~/MATLAB/R2023a/bin:${PATH}

mcc -m -C -v ../src/entrypoint.m \
    -N \
    -a ../src \
    -d ../bin

chmod go+rx ../bin/entrypoint
chmod go+rx ../bin/run_entrypoint.sh
