# springboot-sti
FROM openshift/base-centos7
MAINTAINER Carsten Bucchberger <c.buchberger@witcom.de>

# Install build tools on top of base image
# Java jdk 8, Maven 3.3, Gradle 2.6
ENV MAVEN_VERSION 3.3.9
#http://mirror.23media.de/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
ENV MVN_MIRROR http://mirror.23media.de/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

RUN yum install -y --enablerepo=centosplus \
    tar unzip bc bzip2 which lsof git java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    curl --silent --location https://rpm.nodesource.com/setup_4.x | bash - && \
    yum -y install nodejs && \
    yum clean all -y && \
    (curl -0 $MVN_MIRROR | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    mkdir -p /opt/openshift && chmod -R a+rwX /opt/openshift && \
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src

ENV PATH=/opt/maven/bin/:$PATH


ENV BUILDER_VERSION 1.1

LABEL io.k8s.description="Platform for building jHipster Applications with maven" \
      io.k8s.display-name="jHipster builder 1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="jhipster,builder,maven-3"

# TODO (optional): Copy the builder files into /opt/openshift
# COPY ./<builder_folder>/ /opt/openshift/
# COPY Additional files,configurations that we want to ship by default, like a default setting.xml

LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
COPY ./.s2i/bin/ /usr/local/s2i

RUN chown -R 1001:1001 /opt/openshift

# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
# CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/opt/openshift/app.jar"]
CMD ["usage"]
