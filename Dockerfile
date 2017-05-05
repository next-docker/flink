FROM ping2ravi/jdk:oracle_jdk8.131.11_ubuntu.16.10
MAINTAINER Ravi Sharma

# Flink environment variables
ENV FLINK_INSTALL_PATH=/opt
ENV FLINK_HOME $FLINK_INSTALL_PATH/flink
ENV PATH $PATH:$FLINK_HOME/bin


RUN wget http://mirrors.ukfast.co.uk/sites/ftp.apache.org/flink/flink-1.2.0/flink-1.2.0-bin-hadoop27-scala_2.11.tgz; 
RUN gunzip flink-1.2.0-bin-hadoop27-scala_2.11.tgz ; ls -lrt; 
RUN tar -xvf flink-1.2.0-bin-hadoop27-scala_2.11.tar; ls -lrt
RUN mkdir -p $FLINK_HOME; mv flink-1.2.0/* $FLINK_HOME/.
RUN apt-get update -y; apt-get install -y openssh-server
EXPOSE 8081 6123

COPY docker-entrypoint.sh /
COPY flink-daemon.sh /opt/flink/bin/
COPY jobmanager.sh /opt/flink/bin/
COPY taskmanager.sh /opt/flink/bin/
COPY flink-conf.yaml /opt/flink/conf/

RUN chmod 755 /opt/flink/bin/*.sh; chmod 755 /opt/flink/conf/*.yaml
RUN cp $FLINK_HOME/opt/flink-metrics* $FLINK_HOME/lib/.

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--help"]
