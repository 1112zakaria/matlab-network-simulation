FROM containers.mathworks.com/matlab-runtime

WORKDIR /matlab-server

ADD . /matlab-server/

# Install Python
RUN apt-get update
RUN apt-get -y install python3.9 python3-setuptools python3-pip

# Install Python package dependencies
RUN ls -al packages/*
RUN cd packages/satTest/for_redistribution_files_only && \
    python3 setup.py install
RUN python3 -m pip install -r requirements.txt

# Set environment variables
# Important, set the run-time library path on linux systems:
# https://www.mathworks.com/help/matlab/matlab_external/set-run-time-library-path-on-linux-systems.html
# After investigation, the matlab runtime root is located at /opt/matlabruntime/
ENV FLASK_APP=matlab-server/matlab_server
ENV FLASK_ENV=development
ENV AGREE_TO_MATLAB_RUNTIME_LICENSE=yes
RUN ls -al /usr/local/
RUN ls -al /usr/
RUN ls -al /opt/
RUN ls -al /opt/matlabruntime/*
# RUN ls -al /opt/matlabruntime/runtime
RUN whoami
RUN find /opt/matlabruntime -name "*libmwmclmcrrt.so*"
RUN echo $LD_LIBRARY_PATH

# I have no fucking idea what is going on here. This path was identified based
# on raw trial and error at 5AM in the morning
ENV MATLABROOT1=/opt/matlabruntime
ENV MATLABROOT2=/opt/matlabruntime/R2023b/runtime
ENV LD_LIBRARY_PATH=${MATLABROOT1}/bin/glnxa64:\
${MATLABROOT1}/sys/os/glnxa64:\
${MATLABROOT1}/runtime/glnxa64:\
${MATLABROOT1}/extern/bin/glnxa64\
${MATLABROOT2}/bin/glnxa64:\
${MATLABROOT2}/sys/os/glnxa64:\
# changed this one a bit?
${MATLABROOT2}/glnxa64:\
${MATLABROOT2}/extern/bin/glnxa64
RUN export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$LD_LIBRARY_PATH

CMD echo $LD_LIBRARY_PATH && flask run --host 0.0.0.0

EXPOSE 5000



