FROM gonzalf1/sipm_container:2017.09

#MAINTAINER FG

#ENV http_proxy proxy.sce.com:80
#ENV https_proxy proxy.sce.com:80
RUN yum update -y

#=========================================
# Install Additional System Packages
#=========================================
RUN yum install -y gcc gcc-c++ make openssl-devel aws-cli \
    git \
    tar \
    zip \
    unzip \
    cairo \
    cronie \ 
    tcsh \ 
    wget \
    libgfortran \ 
    curl \
    xml2 \
    libxml2-devel \
    cairo-devel \ 
    giflib-devel \
    libXt-devel    \
    libssh    \
    libssh-devel   \
    libssh2-devel   \
    libcurl-devel 
    libgdal1 libgdal1-dev libgeos libgeos-dev cpp nano vimvim
    
RUN yum groupinstall "Development Tools"
RUN yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel
RUN yum install -y libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel

#libiconv problem
#https://pkgsrc.joyent.com/packages/Linux/el6/trunk/x86_64/All/libiconv-1.14nb3.tgz
#==========================
RUN yum install mysql
RUN mkdir /var/lib/mysql
RUN yum install mysql-server
RUN nano /etc/my.cnf
RUN /etc/init.d/mysqld start
RUN mysqladmin -u root password '123456789'
RUN chkconfig mysqld on
#=========================================
# Install Python 3.5 Packages for SIPM
#=========================================
RUN yum install -y python27-devel pandoc python35-devel python35-libs python35-setuptools && \
    yum clean all

RUN /usr/bin/easy_install-3.5 pip &&\
    pip3 install --upgrade pip
#=========================================
# Install and configure python notebook
#=========================================
RUN curl -s https://bootstrap.pypa.io/get-pip.py | python
RUN pip install jupyter && \
    pip install notebook && \
    pip install jupyterlab && \
    pip --no-cache-dir install pandas pyspark && \
    pip install py4j jupyter-spark lxml && \
    pip install --upgrade beautifulsoup4 html5lib && \
    jupyter nbextension install --py jupyter_spark && \
    jupyter serverextension enable --py jupyter_spark && \
    jupyter nbextension enable --py jupyter_spark && \
    jupyter nbextension enable --py widgetsnbextension

RUN pip install scipy scikit-learn pygments && \
    pip3 install scipy scikit-learn pygments pandas pyspark ipykernel ipython    
#=========================================
#install R
#=========================================
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    yum -y install R
RUN rm -rf /var/cache/yum/* && \
    yum clean all
    
RUN Rscript -e 'install.packages("randomForest", repos="http://cran.mtu.edu")'
RUN Rscript -e 'install.packages("mgcv", repos="http://cran.mtu.edu")'
RUN Rscript -e 'install.packages("MASS", repos="http://cran.mtu.edu")'
RUN Rscript -e 'install.packages("tree", repos="http://cran.mtu.edu")'
RUN Rscript -e 'install.packages("quantregForest", repos="http://cran.mtu.edu")'
RUN Rscript -e 'install.packages("ggplot2", repos="http://cran.mtu.edu")'
RUN Rscript -e 'install.packages("e1071", repos="http://cran.mtu.edu")'
   
RUN jupyter notebook --generate-config --allow-root
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
#=========================================
# Configure Volume
#=========================================
RUN rm -rf /storage && mkdir -p /storage
WORKDIR /storage
VOLUME /storage

#=========================================
# Add bootstrap
#=========================================
COPY bootstrap.sh /etc/bootstrap.sh

RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

EXPOSE 18080 7077 8888 80

ENTRYPOINT ["/etc/bootstrap.sh"]
