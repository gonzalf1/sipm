FROM gonzalf1/sipm_container:2017.09

#ENV http_proxy proxy.sce.com:80
#ENV https_proxy proxy.sce.com:80

RUN yum update -y

# Install System Packages
RUN yum install -y gcc gcc-c++ make openssl-devel aws-cli \
    git \
    tar \
    zip \
    unzip \
    cairo \
    cronie

RUN rm -rf /storage && mkdir -p /storage

WORKDIR /storage

VOLUME /storage

EXPOSE 80

