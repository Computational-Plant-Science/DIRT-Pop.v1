from continuumio/miniconda3

# update packages
run apt-get update && \
    apt-get install -y dirmngr \
    gnupg \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    libcurl4-openssl-dev \
    libssl-dev

# install R
run apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' && \
    add-apt-repository 'deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/' && \
    apt-get update && \
    apt-get install -y r-base r-base-dev

# install R dependencies
run R -e "install.packages('stringr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('tidyr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('lattice',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('reticulate',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('roahd',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('cluster',dependencies=TRUE, repos='http://cran.rstudio.com/')"
run R -e "install.packages('optparse',dependencies=TRUE, repos='http://cran.rstudio.com/')"

# copy sources
workdir /opt/DIRTclust
copy . /opt/DIRTclust

# create environment
run conda env create -f dirtclust.yml

# configure conda env to auto-activate in shells
run conda init bash
run echo "conda activate arbc" > ~/.bashrc

