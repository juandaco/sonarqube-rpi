# Build SonarQube image for Raspberry PI 4
FROM ubuntu:18.04

LABEL version="1.0" \
      description="Sonarqube for Raspberry PI 64bit, with Ubuntu and OpenJDK." \
      mantainer="Juan David Acosta <pagracia@gmail.com>"

# Configuration
ARG SONAR_VERSION=9.3.0.51899
ENV SONAR_VERSION=$SONAR_VERSION
ARG WRAPPER_VERSION=3.5.49
ARG ARCH=arm-64
ARG SONAR_HOME=/opt/sonarqube

# Add needed software and create sonarqube user
RUN apt-get update &&  \
    apt-get -y install openjdk-11-jre-headless unzip wget && \
    rm -rf /var/lib/apt/lists/* && \
    cd /opt && \
    wget -O sonarqube.zip https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip && \
    unzip sonarqube.zip && \
    mv sonarqube-$SONAR_VERSION sonarqube && \
    wget https://download.tanukisoftware.com/wrapper/$WRAPPER_VERSION/wrapper-linux-$ARCH-$WRAPPER_VERSION.tar.gz && \
    tar xzf wrapper-linux-$ARCH-$WRAPPER_VERSION.tar.gz && \
    cp -r sonarqube/bin/linux-x86-64 sonarqube/bin/linux-$ARCH && \
    cp wrapper-linux-$ARCH-$WRAPPER_VERSION/bin/wrapper sonarqube/bin/linux-$ARCH && \
    cp wrapper-linux-$ARCH-$WRAPPER_VERSION/lib/libwrapper.so sonarqube/bin/linux-$ARCH/lib && \
    rm -f sonarqube/lib/jsw/wrapper-*.jar && \
    cp wrapper-linux-$ARCH-$WRAPPER_VERSION/lib/wrapper.jar sonarqube/lib/jsw/wrapper-$WRAPPER_VERSION.jar && \
    useradd -md /opt/sonarqube -s /bin/bash sonarqube && \
    chown -R sonarqube:sonarqube sonarqube && \
    rm -rf wrapper-linux-$ARCH-$WRAPPER_VERSION.* \
           sonarqube.zip \
           sonarqube/bin/win* \
           sonarqube/bin/mac* \
           sonarqube/bin/linux-x86*

WORKDIR $SONAR_HOME
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Configuration
USER sonarqube
EXPOSE 9000
VOLUME $SONAR_HOME/data $SONAR_HOME/temp $SONAR_HOME/extensions $SONAR_HOME/logs

# Start
ENTRYPOINT ["./entrypoint.sh"]
