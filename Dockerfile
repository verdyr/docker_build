FROM       registry.access.redhat.com/ubi7/ubi
#FROM       docker.io/centos:centos7.5.1804
MAINTAINER verdyr

ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=0 \
    JAVA_VERSION_BUILD=141 \
    GRADLE_VERSION_MAJOR=4 \
    GRADLE_VERSION_MINOR=10 \
    SBT_VERSION_MAJOR=1 \
    SBT_VERSION_MINOR=2 \
    SBT_VERSION_MINOR_MINOR=2 \
    MAPR_CLUSTER_VERSION=6.1.0 \
    MEP_VERSION=6.1.0 \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/mapr/lib

#RUN yum install -y --disableplugin=subscription-manager epel-release
RUN yum install -y --disableplugin=subscription-manager https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#RUN yum install -y --disableplugin=subscription-manager centos-release-scl
# for git 2.x from Wandisco repo
RUN yum install -y --disableplugin=subscription-manager http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm


RUN yum install -y --disableplugin=subscription-manager http://mirror.centos.org/centos/7/os/x86_64/Packages/mtools-4.0.18-5.el7.x86_64.rpm
RUN yum install -y --disableplugin=subscription-manager http://mirror.centos.org/centos/7/os/x86_64/Packages/syslinux-4.05-15.el7.x86_64.rpm
#RUN yum install -y --disableplugin=subscription-manager less more git wget curl httpd java-1.${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}-openjdk-devel unzip make which nano vim gdb gcc gcc-c++ python36-pip.noarch python36-devel.x86_64 golang strace route iproute traceroute ethtool net-tools jq bind-utils && yum -q --disableplugin=subscription-manager clean all
RUN yum install -y --disableplugin=subscription-manager less more git wget curl httpd java-1.${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}-openjdk-devel unzip make which nano vim gdb gcc gcc-c++ python36-pip.noarch python36-devel.x86_64 strace route iproute traceroute ethtool net-tools jq bind-utils && yum -q --disableplugin=subscription-manager clean all
RUN yum update all -y --disableplugin=subscription-manager && yum -q --disableplugin=subscription-manager clean all

RUN cd /opt && wget -v https://www-eu.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz && tar zxvf apache-maven-3.6.0-bin.tar.gz && rm apache-maven-3.6.0-bin.tar.gz && /opt/apache-maven-3.6.0/bin/mvn -v
ENV PATH "/opt/apache-maven-3.6.0/bin:$PATH"

#RUN git clone https://github.com/operator-framework/operator-sdk /opt/operator-sdk && cd /opt/operator-sdk && git checkout master && make dep && make install


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

LABEL df.os=UBI7 df.version=0.1.1 df.client_version=0.0.1

#COPY df_client_setup.sh /opt/df/setup/df_client_setup.sh

COPY vim_pathogen.sh /opt/vim_pathogen.sh

# tst comment here

#RUN useradd sboldyrev001

## mapr specific, separately
RUN yum install -y --disableplugin=subscription-manager http://archive.mapr.com/releases/v${MAPR_CLUSTER_VERSION}/redhat/mapr-librdkafka-0.11.3.201803231414-1.noarch.rpm
RUN yum install -y --disableplugin=subscription-manager http://archive.mapr.com/releases/v${MAPR_CLUSTER_VERSION}/redhat/mapr-client-6.1.0.20180926230239.GA-1.x86_64.rpm
RUN yum install -y --disableplugin=subscription-manager http://package.mapr.com/releases/v${MAPR_CLUSTER_VERSION}/redhat/mapr-posix-client-container-6.1.0.20180926230239.GA-1.x86_64.rpm
RUN yum install -y --disableplugin=subscription-manager http://archive.mapr.com/releases/MEP/MEP-${MEP_VERSION}/redhat/mapr-spark-2.3.2.0.201901301208-1.noarch.rpm
RUN pip3.6 install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" mapr-streams-python


RUN /opt/mapr/server/configure.sh -N cdp.cluster.name.org -c -secure -C cldb_node1:7222,cldb_node2:7222,cldb_node3:7222 -HS HS_node

#RUN git config --global user.email "sergey.boldyrev@pwc.com" && git config --global user.name "Serguei Boldyrev"

ENV JAVA_MAX_MEM=1200m \
    JAVA_MIN_MEM=1200m

CMD ["/bin/bash"]
