FROM quay.io/justcontainers/base:v0.7.2
MAINTAINER Gorka Lerchundi Osa <glertxundi@gmail.com>

##
## INSTALL
##

# define env vars
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV JIRA_HOME /var/lib/jira

# accept terms and add custom oracle repo
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java

# install oracle java 8
RUN apt-get-min update                         && \
    apt-get-install-min oracle-java8-installer

# create jira user
RUN useradd -r --create-home --home-dir /opt/jira --shell /bin/false jira

# atlassian jira
ADD https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.4.tar.gz /tmp/atlassian-jira.tar.gz
RUN tar xvfz /tmp/atlassian-jira.tar.gz -C /opt/jira --strip 1 --owner jira --group jira && \
    echo "jira.home = ${JIRA_HOME}" > /opt/jira/atlassian-jira/WEB-INF/classes/jira-application.properties && \
    chown -R jira:jira /opt/jira

# mysql connector
ADD http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.35.tar.gz /tmp/mysql-connector.tar.gz
RUN tar xvfz /tmp/mysql-connector.tar.gz -C /opt/jira/lib --strip 1 --wildcards --no-anchored 'mysql-connector-java-5.1.35-bin.jar'

# confd
ADD https://github.com/glerchundi/confd/releases/download/v0.10.0-beta2/confd-0.10.0-beta2-linux-amd64 /usr/bin/confd
RUN chmod 0755 /usr/bin/confd

##
## ROOTFS
##

# root filesystem
COPY rootfs /

# data & log volumes
VOLUME [ "/var/lib/jira" ]

# ports (http)
EXPOSE 8080

##
## CLEANUP
##

RUN apt-cleanup
