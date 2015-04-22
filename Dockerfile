#Set the base image :
FROM oraclelinux:6.6

#File Author/Maintainer :
MAINTAINER Sasikanth Kotti <kotti.sasikanth@gmail.com>

#Update packages and install wget and man :
RUN yum update -y -q
RUN yum install -y -q wget man tar sudo zip unzip ping glibc make binutils gcc libaio bc perl binutils compat-libstd* elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel libaio libaio-devel libgcc libstdc++ libstd c++-devel make sysstat
RUN yum reinstall -y -q glibc-common
RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8
RUN yum reinstall -y -q --exclude=filesystem-2.4.30-3.el6.x86_64 \*
RUN useradd obiee

#Set workdir to /opt/Middleware :
WORKDIR /opt/Middleware

#Obtain/download Java SE Development Kit 7u75 using wget :
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.tar.gz

#Set permissions to Middleware directory to enable obiee user perform operations :
RUN chmod 777 /opt/Middleware

#Set the username to obiee :
USER obiee

#Setup jdk1.7.0_71 and create softlink :
RUN gunzip jdk-7u71-linux-x64.tar.gz
RUN tar -xvf jdk-7u71-linux-x64.tar
RUN ln -s jdk1.7.0_71 current_java
RUN rm jdk-7u71-linux-x64.tar

#Setup environment variables for java :
ENV JAVA_HOME /opt/Middleware/current_java
ENV PATH $PATH:/opt/Middleware/current_java:/opt/Middleware/current_java/bin

#Add weblogic installation file and configuration file for silent installation :
ADD ./wls1036_generic.jar /opt/Middleware/
ADD ./silent.xml /opt/Middleware/

#Silent Installation of weblogic :
RUN java -Xmx1024m -jar wls1036_generic.jar -mode=silent -silent_xml=/opt/Middleware/silent.xml

ADD ./bi_linux_x86_111170_64_disk1_2of2.zip /opt/Middleware/
ADD ./bi_linux_x86_111170_64_disk1_1of2.zip /opt/Middleware/
ADD ./bi_linux_x86_111170_64_disk2_1of2.zip /opt/Middleware/
ADD ./bi_linux_x86_111170_64_disk2_2of2.zip /opt/Middleware/
ADD ./bi_linux_x86_111170_64_disk3.zip /opt/Middleware/
ADD ./obi_install.rsp /opt/Middleware/
ADD ./obi_config.rsp /opt/Middleware/
ADD ./oraInst.loc /opt/Middleware/

#ADD ./oracle-xe-11.2.0-1.0.x86_64.rpm.zip /opt/Middleware/
#ADD ./xe.rsp /opt/Middleware/

RUN unzip ./bi_linux_x86_111170_64_disk1_1of2.zip
RUN unzip ./bi_linux_x86_111170_64_disk1_2of2.zip
RUN unzip ./bi_linux_x86_111170_64_disk2_1of2.zip
RUN unzip ./bi_linux_x86_111170_64_disk2_2of2.zip
RUN unzip ./bi_linux_x86_111170_64_disk3.zip

RUN rm bi_linux_x86_111170_64_disk1_1of2.zip bi_linux_x86_111170_64_disk1_2of2.zip bi_linux_x86_111170_64_disk2_1of2.zip bi_linux_x86_111170_64_disk2_2of2.zip bi_linux_x86_111170_64_disk3.zip


USER obiee
#Install OBIEE 11g
RUN /opt/Middleware/bishiphome/Disk1/runInstaller -silent -response /opt/Middleware/obi_install.rsp -invPtrLoc /opt/Middleware/oraInst.loc -ignoreSysPrereqs -waitforcompletion

#Set the username to root and hostname to OBIEE11117Linux
USER root
ENV HOSTNAME OBIEE11117Linux
#RUN hostname OBIEE11117Linux
RUN hostname

USER obiee
ENV LANG en_US.UTF-8

CMD /opt/Middleware/weblogic/Oracle_BI1/bin/config.sh -silent -response /opt/Middleware/obi_config.rsp -ignoreSysPrereqs -waitforcompletion

#RUN yum install -y -q glibc make binutils gcc libaio bc

#RUN dd if=/dev/zero of=/opt/myswapfile bs=1024 count=2097152
#RUN mkswap /opt/myswapfile
#RUN swapon /opt/myswapfile

#RUN unzip oracle-xe-11.2.0-1.0.x86_64.rpm.zip
#RUN rpm -ivh /opt/Middleware/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm > ./XEsilentinstall.log
#RUN mount -t tmpfs shmfs -o size=12g /dev/shm
#RUN /etc/init.d/oracle-xe configure responseFile=/opt/Middleware/xe.rsp >> ./XEsilentinstall.log
