FROM jupyter/base-notebook

# Add RUN statements to install packages as the $NB_USER defined in the base images.

# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
# change file permissions, etc.

# If you do switch to root, always be sure to add a "USER $NB_USER" command at the end of the
# file to ensure the image runs as a unprivileged user by default.

USER root

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
RUN add-apt-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' -y

RUN apt-get -y install \
    git \
    cmake \
    libboost-program-options-dev \
    apt-utils \
    build-essential \
    cmake \
    doxygen \
    texlive-latex-base \
    libboost-all-dev \
    python-vtk6 \
    python-dev \
    x11vnc \
    wmctrl \
    xvfb -y


##COPY opencamlib /opencamlib
RUN git clone --depth=50 --branch=master https://github.com/aewallin/opencamlib.git opencamlib

ENV CXX g++
ENV CC gcc
ENV DISPLAY :20

RUN pip install ipywidgets


RUN add-apt-repository ppa:freecad-maintainers/freecad-stable -y
#RUN add-apt-repository ppa:freecad-maintainers/freecad-daily -y
RUN apt-get update
#RUN apt-get -y install freecad-daily
RUN apt-get -y install freecad

RUN mkdir opencamlib/build
RUN cd opencamlib/build && cmake -DBUILD_PY_LIB=ON -DUSE_PY_3=ON ../src -Wno-dev && make && make install

RUN pip install ipyvolume
RUN ln -s /usr/lib/freecad/Mod /usr/lib/freecad-python3/Mod
USER $NB_USER

RUN cd
COPY testfiles/* /home/jovyan/work/
COPY examples/* /home/jovyan/work/

# Trust all notebooks
RUN find /home/jovyan/work -name '*.ipynb' -exec jupyter trust {} \;

RUN cd ~/work

ENV PATH="/usr/lib/freecad/lib:${PATH}"
ENV PYTHONPATH="/usr/lib/freecad/lib:${PATH}"
