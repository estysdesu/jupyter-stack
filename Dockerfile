FROM jupyter/minimal-notebook:latest

LABEL Description="Jupyter w/ Python 3.8 and my own options and custom kernels"
LABEL Maintainer="Tyler Estes <estysdesu@gmail.com>"

ARG NB_USER="estysdesu"
ARG NB_UID="5000"
ARG NB_GID="5000"
ARG conda_env=python38
ARG py_ver=3.8

ENV NB_USER=$NB_USER \
    NB_GROUP=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    HOME=/home/$NB_USER \
    CHOWN_HOME=yes \
    CHOWN_HOME_OPTS='-R' \
    GRANT_SUDO=yes \
    JUPYTER_ENABLE_LAB=yes \
    RESTARTABLE=yes

CMD ["start-notebook.sh", "--LabApp.token=''"]

##### ##### ##### ##### ##### ##### ##### #####
##### CONDA ENV                           #####
##### ##### ##### ##### ##### ##### ##### #####
RUN conda create -q -y -p $CONDA_DIR/envs/$conda_env -c conda-forge python=$py_ver \
    ipython \
    ipykernel \
    && \
    conda clean --all -f -y

RUN $CONDA_DIR/envs/${conda_env}/bin/python -m ipykernel install \
    --prefix="${CONDA_DIR}"
    --name="${conda_env}" \
    --display-name='Python 3.8' && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# RUN $CONDA_DIR/envs/${conda_env}/bin/pip install

ENV PATH=$CONDA_DIR/envs/${conda_env}/bin:$PATH
ENV CONDA_DEFAULT_ENV=${conda_env}

##### ##### ##### ##### ##### ##### ##### #####
##### JULIA KERNEL                        #####
##### ##### ##### ##### ##### ##### ##### #####
# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile

USER root

ENV JULIA_PKGDIR=/opt/julia

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    julia \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN printf "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")\n" \
    >> /etc/julia/juliarc.jl && \
    mkdir -p "${JULIA_PKGDIR}" && \
    chown "${NB_USER}" "${JULIA_PKGDIR}" && \
    fix-permissions "${JULIA_PKGDIR}"

USER $NB_USER

RUN julia -e 'import Pkg; Pkg.update()' && \
    julia -e "using Pkg; pkg\"add IJulia\"; pkg\"precompile\"" && \
    mv "${HOME}/.local/share/jupyter/kernels/julia"* "${CONDA_DIR}/share/jupyter/kernels/" && \
    chmod -R go+rx "${CONDA_DIR}/share/jupyter" && \
    rm -rf "${HOME}/.local" && \
    fix-permissions "${JULIA_PKGDIR}" "${CONDA_DIR}/share/jupyter"

##### ##### ##### ##### ##### ##### ##### #####
##### OCTAVE KERNEL                       #####
##### ##### ##### ##### ##### ##### ##### #####
# https://github.com/rubenv/jupyter-octave/blob/master/Dockerfile

USER root

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    octave \
    octave-data-smoothing \
    octave-database \
    octave-image \
    octave-io \
    octave-miscellaneous \
    octave-missing-functions \
    octave-nan \
    octave-nurbs \
    octave-signal \
    octave-splines \
    octave-statistics \
    octave-strings \
    octave-struct \
    octave-symbolic \
    gnuplot \
    ghostscript \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER $NB_USER

RUN conda install -y -q octave_kernel && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
