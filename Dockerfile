FROM       docker.io/centos:centos7.5.1804
MAINTAINER verdyr

ARG VERSION=1.15.0
RUN echo $VERSION
ARG MIRROR=http://apache.claz.org/drill
RUN echo $MIRROR

ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=0 \
    JAVA_VERSION_BUILD=141 \
    GRADLE_VERSION_MAJOR=4 \
    GRADLE_VERSION_MINOR=10 \
    SBT_VERSION_MAJOR=1 \
    SBT_VERSION_MINOR=2 \
    SBT_VERSION_MINOR_MINOR=3 \
    MAPR_CLUSTER_VERSION=6.1.0 \
    MEP_VERSION=6.1.0 \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/mapr/lib

RUN yum install -y epel-release
RUN yum install -y centos-release-scl
RUN yum install -y http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm

RUN yum install -y systemd less more git wget curl httpd java-1.${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR} python2-pip python-devel maven unzip make which nano vim gdb gcc strace route iproute traceroute ethtool net-tools && yum -q clean all

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

LABEL df.os=centos7 df.version=0.0.1 df.client_version=0.0.1

#COPY df_client_setup.sh /opt/df/setup/df_client_setup.sh 

# tst comment here

RUN useradd verdyr

## mapr specific, separately
RUN yum install -y http://archive.mapr.com/releases/v${MAPR_CLUSTER_VERSION}/redhat/mapr-librdkafka-0.11.3.201803231414-1.noarch.rpm
RUN yum install -y http://archive.mapr.com/releases/v${MAPR_CLUSTER_VERSION}/redhat/mapr-client-6.1.0.20180926230239.GA-1.x86_64.rpm

RUN yum install -y http://package.mapr.com/releases/v${MAPR_CLUSTER_VERSION}/redhat/mapr-posix-client-container-6.1.0.20180926230239.GA-1.x86_64.rpm
RUN yum install -y http://archive.mapr.com/releases/MEP/MEP-${MEP_VERSION}/redhat/mapr-spark-2.3.2.0.201901301208-1.noarch.rpm
RUN pip install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" mapr-streams-python

# cluster specific
# RUN /opt/mapr/server/configure.sh 

ENV JAVA_MAX_MEM=1200m \
    JAVA_MIN_MEM=1200m

RUN echo 'root:drill' | chpasswd

ADD $MIRROR/drill-$VERSION/apache-drill-$VERSION.tar.gz /tmp/
RUN mkdir /opt/drill
RUN tar -zxf /tmp/apache-drill-$VERSION.tar.gz --directory=/opt/drill --strip-components 1
RUN rm -f /tmp/apache-drill-$VERSION.tar.gz

RUN chown -R root:root /opt/drill

RUN echo "select * from sys.version;" > /tmp/version.sql
RUN /opt/drill/bin/sqlline -u jdbc:drill:zk=local --run=/tmp/version.sql


CMD ["/bin/bash"]
