# jupyter-stack
![](https://github.com/estysdesu/jupyter-stack/workflows/CI/badge.svg)

jupyter-stack is a my personal maintained Jupyter Docker Stack image for use on my self-hosted server

## TODO
- [ ] Update `WORKDIR` (`WORKDIR "/home/$NB_USER/work`)
- [ ] Install and configure plugins and theming
```
overrides.json
{
  "@jupyterlab/apputils-extension:themes": {
    "theme": "Rahlir Gruvbox"
  }
}
```
```
conda requirements

RUN conda install --quiet --yes \
    jupyter \
    jupyter-console \
    jupyterlab==1.2.7 # pin for upstream conflict w/ jupyterlab_vim \
    numpy \
    pandas \
    scipy \
    sympy \
    matplotlib \
    bokeh \
    ipympl \
    pandoc \
    dask_labextension \
    && \
    conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN conda install -c conda-forge nodejs
RUN conda install --quiet --yes jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --user && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter nbextension enable hinterland/hinterland
RUN jupyter labextension install -y --clean @jupyter-widgets/jupyterlab-manager && \
    jupyter-matplotlib && \
    dask-labextension && \
    jupyterlab_vim && \
    @rahlir/theme-gruvbox

##### ##### ##### ##### ##### ##### ##### #####
##### JUPYTER SETTINGS                    #####
##### ##### ##### ##### ##### ##### ##### #####
RUN mkdir -p $CONDA_DIR/share/jupyter/lab/settings
COPY overrides.json $CONDA_DIR/share/jupyter/lab/settings/
```
- [ ] Update testing suite ([docs](https://docs.pytest.org/en/5.4.3/getting-started.html))
- [ ] Reduce image size (currently > 1.5 GB) by building from Alpine ([base Dockerfile](https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile), [apk pkgs](https://pkgs.alpinelinux.org/packages?name=python*&branch=v3.12))
