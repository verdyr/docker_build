FROM       registry.access.redhat.com/ubi7/ubi

MAINTAINER verdyr

ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=0 \
    JAVA_VERSION_BUILD=141 \
    GRADLE_VERSION_MAJOR=4 \
    GRADLE_VERSION_MINOR=10 \
    SBT_VERSION_MAJOR=1 \
    SBT_VERSION_MINOR=2 \
    SBT_VERSION_MINOR_MINOR=2


# Install vim-8 to use with tabnine ML assistant
RUN rpm -Uvh http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el7.noarch.rpm && rpm --import http://mirror.ghettoforge.org/distributions/gf/RPM-GPG-KEY-gf.el7
RUN yum install -y --enablerepo=gf-plus --disableplugin=subscription-manager vim-enhanced

RUN yum install -y --disableplugin=subscription-manager https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y --disableplugin=subscription-manager http://mirror.centos.org/centos/7/extras/x86_64/Packages/centos-release-scl-rh-2-3.el7.centos.noarch.rpm
RUN yum install -y --disableplugin=subscription-manager http://mirror.centos.org/centos/7/extras/x86_64/Packages/centos-release-scl-2-2.el7.centos.noarch.rpm
RUN yum --enablerepo=centos-sclo-rh-testing install -y  --disableplugin=subscription-manager rh-maven35-maven-compiler-plugin
# for git 2.x from Wandisco repo
RUN yum install -y --disableplugin=subscription-manager http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm

RUN yum install -y --disableplugin=subscription-manager http://mirror.centos.org/centos/7/os/x86_64/Packages/mtools-4.0.18-5.el7.x86_64.rpm
RUN yum install -y --disableplugin=subscription-manager http://mirror.centos.org/centos/7/os/x86_64/Packages/syslinux-4.05-15.el7.x86_64.rpm

RUN yum install -y --disableplugin=subscription-manager less more git wget curl httpd java-1.${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}-openjdk-devel unzip make which nano gdb gcc gcc-c++ python36-pip.noarch python36-devel.x86_64 strace route iproute traceroute ethtool net-tools nfs-utils bind-utils jq && yum -q --disableplugin=subscription-manager clean all
RUN cd /opt && wget -v https://www-eu.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz && tar zxvf apache-maven-3.6.0-bin.tar.gz && rm apache-maven-3.6.0-bin.tar.gz && /opt/apache-maven-3.6.0/bin/mvn -v
RUN export PATH=/opt/apache-maven-3.6.0/bin:$PATH


#RUN mkdir $HOME/go/bin && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
#ENV GOPATH=$HOME/go
#ENV PATH=$PATH:$HOME/go/bin
#RUN git clone https://github.com/operator-framework/operator-sdk /opt/operator-sdk
# && cd /opt/operator-sdk && git checkout master && make dep && make install


RUN cd /usr/share && \
#    curl --fail --silent --location --retry 3 \
    wget -v https://services.gradle.org/distributions/gradle-${GRADLE_VERSION_MAJOR}.${GRADLE_VERSION_MINOR}-bin.zip && \
    unzip gradle-${GRADLE_VERSION_MAJOR}.${GRADLE_VERSION_MINOR}-bin.zip && \
    rm gradle-${GRADLE_VERSION_MAJOR}.${GRADLE_VERSION_MINOR}-bin.zip
    
#RUN cd /usr/share && \
#    wget -v https://github.com/sbt/sbt/releases/download/v${SBT_VERSION_MAJOR}.${SBT_VERSION_MINOR}.${SBT_VERSION_MINOR_MINOR}/sbt-${SBT_VERSION_MAJOR}.${SBT_VERSION_MINOR}.${SBT_VERSION_MINOR_MINOR}.zip && \
#    unzip sbt-${SBT_VERSION_MAJOR}.${SBT_VERSION_MINOR}.${SBT_VERSION_MINOR_MINOR}.zip && \
#    rm sbt-${SBT_VERSION_MAJOR}.${SBT_VERSION_MINOR}.${SBT_VERSION_MINOR_MINOR}.zip

# Path to update, TODO

LABEL df.os=ubi7 df.version=0.1.1 df.client_version=0.1.1

#COPY df_client_setup.sh /opt/df/setup/df_client_setup.sh

COPY vim_pathogen.sh /opt/vim_pathogen.sh
COPY operator_env.sh /opt/operator_env.sh

# tst comment here

#RUN   git config --global user.email "sergey.boldyrev@pwc.com" && git config --global user.name "Serguei Boldyrev"

ENV JAVA_MAX_MEM=1200m \
    JAVA_MIN_MEM=1200m

#RUN mkdir $HOME/go/bin && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

CMD ["/bin/bash"]
