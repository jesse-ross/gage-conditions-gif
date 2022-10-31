ARG DOCKER_BASE_IMAGE=eddelbuettel/r2u:jammy
FROM ${DEVOPS_REGISTRY}${DOCKER_BASE_IMAGE}

# Disable the annoying bell on WSL2
RUN sed -i 's/^# set bell-style none$/set bell-style none/' /etc/inputrc
RUN echo 'set visualbell' >> /root/.vimrc

# Add DOI CA to local CAs so that SSL can work over VPN
COPY docker/DOIRootCA2.crt /usr/local/share/ca-certificates
RUN update-ca-certificates
ENV CURL_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt

RUN install2.r \
  assertthat \
  aws.ec2metadata \
  aws.s3 \
  aws.signature \
  crayon \
  dataRetrieval \
  digest \
  dplyr \
  lubridate \
  maptools \
  optparse \
  readr \
  progress \
  purrr \
  R6 \
  remotes \
  rgdal \
  rgeos \
  showtext \
  sf \
  sp \
  storr \
  tidyr \
  whisker \
  yaml \
  && rm -rf /tmp/*

RUN installGithub.r --update=FALSE \
  richfitz/remake \
  && rm -rf /tmp/*

RUN installGithub.r --update=FALSE \
  jesse-ross/scipiper@use-ec2-metadata \
  && rm -rf /tmp/*/* /tmp/*

# Use UTC instead of local time zones
ENV TZ=Etc/UTC

# expose information about the build environment within containers
ARG DOCKER_BUILD_REPO
ENV DOCKER_BUILD_REPO ${DOCKER_BUILD_REPO}
ARG DOCKER_BUILD_COMMIT_HASH
ENV DOCKER_BUILD_COMMIT_HASH ${DOCKER_BUILD_COMMIT_HASH}

# suppress an annoying message from bspm
RUN mkdir /usr/local/lib/R/etc/
RUN echo 'options(bspm.sudo = TRUE)' >> /usr/local/lib/R/etc/Rprofile.site

# Copy repo into image, so the image contains the code it needs to run on ECS.
# Note: here / is root of build context, NOT file system.
COPY / /gage-conditions/
