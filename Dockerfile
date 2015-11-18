# ---------------------------------------------
#
# Dockerfile best practices
# Refer: http://docs.docker.com/engine/articles/dockerfile_best-practices/
#
# For information on the phusion baseimage
# Refer: https://phusion.github.io/baseimage-docker/
#
# ---------------------------------------------

FROM phusion/baseimage:0.9.17

MAINTAINER "Science IS Team" ws@sit.auckland.ac.nz

# set environment variables
ENV SHINY_VERSION http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.3.0.403-amd64.deb

# Add the CRAN PPA to get all versions of R and install base R
RUN echo 'deb http://cran.stat.auckland.ac.nz/bin/linux/ubuntu trusty/' > /etc/apt/sources.list.d/cranppa.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
    && apt-get -y update \
    && apt-get -y install --no-install-recommends \
    r-base \
    libcurl4-openssl-dev \
    libxml2-dev \
    gdebi-core \
    wget \
    make \
    gcc \
    g++ \
    git

# download and install shiny server
RUN wget --no-verbose -O shiny-server.deb ${SHINY_VERSION} \
    && gdebi -n shiny-server.deb \
    && rm -f shiny-server.deb

# install R packages
RUN R -e "install.packages(c('rmarkdown', 'devtools', 'shiny', 'DT'), repos='http://cran.rstudio.com/', lib='/usr/lib/R/site-library', dependencies=T)" \
    && R -e "devtools::install_github('ramnathv/rCharts')"
    
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose ports
EXPOSE 3838

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
