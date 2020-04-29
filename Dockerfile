# ---------------------------------------------
#
# Dockerfile best practices
# Refer: http://docs.docker.com/engine/articles/dockerfile_best-practices/
#
# This file makes use of contributions from Rafal Szkup, Application Engineer, UoA
# and the iNZight Team, UoA
#
# ---------------------------------------------

# start with a light-weight base image
FROM debian:buster 

MAINTAINER "Science IS Team" ws@sit.auckland.ac.nz

ENV BUILD_DATE "2015-12-03"

# Add the CRAN PPA to get all versions of R and install base R and required packages
# install shiny server and clean up all downloaded files to make sure the image remains lean as much as possible
# NOTE: we group a lot of commands together to reduce the number of layers that Docker creates in building this image

COPY shiny-server.sh /opt/

RUN apt-get update && apt-get install -y gnupg2\
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FCAE2A0E115C3D8A \
    && echo "deb http://cloud.r-project.org/bin/linux/debian buster-cran40/" | tee -a /etc/apt/sources.list.d/R.list \
    && apt-get update \
    && apt-get install -y -q \
        -t buster-cran40 r-base\
        libssl-dev \
        libssl1.1 \
        sudo \
        wget \
    && R -e "install.packages(c('rmarkdown', 'shiny', 'DT'), repos='http://cran.rstudio.com/', lib='/usr/lib/R/site-library')" \
    && wget --no-verbose -O shiny-server.deb https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.13.944-amd64.deb \
    && dpkg -i shiny-server.deb \
    && chmod +x /opt/shiny-server.sh \
    && rm -f shiny-server.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose ports
EXPOSE 3838

# we do NOT initiate any process - treat this image as abstract class equivalent

