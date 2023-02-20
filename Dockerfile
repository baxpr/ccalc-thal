FROM centos:7

# Initial system
# bc libgomp perl tcsh vim-common                    for FS
#     mesa-libGL libXext libSM libXrender libXmu
# java-1.8.0-openjdk                                 for MCR
# mesa-libGLU mesa-dri-drivers                       for FS with xvfb
# xorg-x11-server-Xvfb xorg-x11-xauth which          xvfb
RUN yum -y update && \
    yum -y install wget tar zip unzip && \
    yum -y install bc libgomp perl tcsh vim-common && \
    yum -y install mesa-libGL libXext libSM libXrender libXmu && \
    yum -y install java-1.8.0-openjdk && \
    yum -y install mesa-libGLU mesa-dri-drivers && \
    yum -y install xorg-x11-server-Xvfb xorg-x11-xauth which && \
    yum -y install ImageMagick && \
    yum clean all

# Install the MCR
RUN wget -nv https://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/6/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_6_glnxa64.zip \
    -O /opt/mcr_installer.zip && \
    unzip /opt/mcr_installer.zip -d /opt/mcr_installer && \
    /opt/mcr_installer/install -mode silent -agreeToLicense yes && \
    rm -r /opt/mcr_installer /opt/mcr_installer.zip

# Matlab env
ENV MATLAB_SHELL=/bin/bash
ENV MATLAB_RUNTIME=/usr/local/MATLAB/MATLAB_Runtime/v97

# Install Freesurfer (freeview only)
RUN wget -nv https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.2.0/freesurfer-linux-centos7_x86_64-7.2.0.tar.gz \
    -O /opt/freesurfer.tgz && \
    mkdir -p /usr/local/freesurfer/bin /usr/local/freesurfer/lib/vtk && \
    tar -zxf /opt/freesurfer.tgz -C /usr/local freesurfer/bin/freeview && \
    tar -zxf /opt/freesurfer.tgz -C /usr/local freesurfer/bin/qt.conf && \
    tar -zxf /opt/freesurfer.tgz -C /usr/local freesurfer/build-stamp.txt && \
    tar -zxf /opt/freesurfer.tgz -C /usr/local freesurfer/SetUpFreeSurfer.sh && \
    tar -zxf /opt/freesurfer.tgz -C /usr/local freesurfer/FreeSurferEnv.sh && \
    tar -zxf /opt/freesurfer.tgz -C /usr/local freesurfer/lib/qt && \
    tar -zxf /opt/freesurfer.tgz -C /usr/local freesurfer/lib/vtk && \
    rm /opt/freesurfer.tgz
 
# Freesurfer env
ENV OS=Linux
ENV PATH=/usr/local/freesurfer/bin:/usr/local/freesurfer/fsfast/bin:/usr/local/freesurfer/tktools:/usr/local/freesurfer/mni/bin:${PATH}
ENV FREESURFER_HOME=/usr/local/freesurfer
ENV FREESURFER=/usr/local/freesurfer
ENV SUBJECTS_DIR=/usr/local/freesurfer/subjects
ENV LOCAL_DIR=/usr/local/freesurfer/local
ENV FSFAST_HOME=/usr/local/freesurfer/fsfast
ENV FMRI_ANALYSIS_DIR=/usr/local/freesurfer/fsfast
ENV FUNCTIONALS_DIR=/usr/local/freesurfer/sessions
ENV FS_OVERRIDE=0
ENV FIX_VERTEX_AREA=""
ENV FSF_OUTPUT_FORMAT=nii.gz
ENV XDG_RUNTIME_DIR=/tmp
ENV MINC_BIN_DIR=/usr/local/freesurfer/mni/bin
ENV MINC_LIB_DIR=/usr/local/freesurfer/mni/lib
ENV MNI_DIR=/usr/local/freesurfer/mni
ENV MNI_DATAPATH=/usr/local/freesurfer/mni/data
ENV MNI_PERL5LIB=/usr/local/freesurfer/mni/share/perl5
ENV PERL5LIB=/usr/local/freesurfer/mni/share/perl5

# We need to make the ImageMagick security policy more permissive 
# to be able to write PDFs.
COPY ImageMagick-policy.xml /etc/ImageMagick-6/policy.xml

# Copy the pipeline code. Matlab must be compiled before building. 
COPY build /opt/conncalc/build
COPY bin /opt/conncalc/bin
COPY src /opt/conncalc/src
COPY README.md /opt/conncalc

# Add pipeline to system path
ENV PATH=/opt/conncalc/src:/opt/conncalc/bin:${PATH}

# Matlab executable must be run at build to extract the CTF archive
RUN run_spm12.sh ${MATLAB_RUNTIME} function quit

# Entrypoint
ENTRYPOINT ["xwrapper.sh","conncalc.sh"]
