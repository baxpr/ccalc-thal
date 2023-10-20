FROM baxterprogers/fsl-base:v6.0.5.2

# Install the MCR
RUN wget -nv https://ssd.mathworks.com/supportfiles/downloads/R2023a/Release/5/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2023a_Update_5_glnxa64.zip \
    -O /opt/mcr_installer.zip && \
    unzip /opt/mcr_installer.zip -d /opt/mcr_installer && \
    /opt/mcr_installer/install -mode silent -agreeToLicense yes && \
    rm -r /opt/mcr_installer /opt/mcr_installer.zip

# Matlab env
ENV MATLAB_SHELL=/bin/bash
ENV MATLAB_RUNTIME=/usr/local/MATLAB/MATLAB_Runtime/v914

# We need to make the ImageMagick security policy more permissive 
# to be able to write PDFs.
COPY ImageMagick-policy.xml /etc/ImageMagick-6/policy.xml

# Copy the pipeline code. Matlab must be compiled before building. 
COPY matlab /opt/ccalc-thal/matlab
COPY src /opt/ccalc-thal/src
COPY README.md /opt/ccalc-thal

# Add pipeline to system path
ENV PATH=/opt/ccalc-thal/src:/opt/ccalc-thal/matlab/bin:${PATH}

# Matlab executable must be run at build to extract the CTF archive
RUN run_spm12.sh ${MATLAB_RUNTIME} function quit

# Entrypoint
ENTRYPOINT ["xwrapper.sh","entrypoint.sh"]
