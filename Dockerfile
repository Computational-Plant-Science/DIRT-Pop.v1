from r-base:4.2.2

# copy sources
copy . /opt/DIRTclust
workdir /opt/DIRTclust

# install R dependencies
run R -e "install.packages('stringr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('tidyr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('lattice',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('reticulate',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('roahd',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('cluster',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('optparse',dependencies=TRUE, repos='http://cran.rstudio.com/')"

# install conda
env PATH="/root/miniconda3/bin:${PATH}"
arg PATH="/root/miniconda3/bin:${PATH}"
run wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.1.0-1-Linux-x86_64.sh -O install_conda.sh && \
    chmod +x install_conda.sh && \
    ./install_conda.sh -b

# create conda env and configure run commands to use it
run conda env create -f dirtclust.yml
shell ["conda", "run", "-n", "arbc", "/bin/bash", "-c"]

entrypoint ["conda", "run", "--no-capture-output", "-n", "arbc", "./wrapper.sh"]
