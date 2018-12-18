FROM       docker.io/centos:centos7.5.1804
MAINTAINER verdyr

#Available Environment Groups:
#   Minimal Install
#   Compute Node
#   Infrastructure Server
#   File and Print Server
#   Cinnamon Desktop
#   MATE Desktop
#   Basic Web Server
#   Virtualization Host
#   Server with GUI
#   GNOME Desktop
#   KDE Plasma Workspaces
#   Development and Creative Workstation
#Available Groups:
#   Cinnamon
#   Compatibility Libraries
#   Console Internet Tools
#   Development Tools
#   Educational Software
#   Electronic Lab
#   Fedora Packager
#   General Purpose Desktop
#   Graphical Administration Tools
#   Haskell
#   Legacy UNIX Compatibility
#   MATE
#   Milkymist
#   Scientific Support
#   Security Tools
#   Smart Card Support
#   System Administration Tools
#   System Management
#   TurboGears application framework
#   Xfce


ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=0 \
    JAVA_VERSION_BUILD=141 \
    GRADLE_VERSION_MAJOR=4 \
    GRADLE_VERSION_MINOR=10 \
    SBT_VERSION_MAJOR=1 \
    SBT_VERSION_MINOR=2 \
    SBT_VERSION_MINOR_MINOR=2 \
    MAPR_CLUSTER_VERSION=6.1.0 \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/mapr/lib

RUN yum install -y epel-release

RUN yum install -y systemd less more git wget curl httpd java-1.${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR} python2-pip python-devel maven unzip make which nano vim gdb gcc gcc-c++ strace route iproute traceroute ethtool net-tools nfs-utils npm && yum -q clean all

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
RUN pip install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" mapr-streams-python


ENV JAVA_MAX_MEM=1200m \
    JAVA_MIN_MEM=1200m

CMD ["/bin/bash"]
