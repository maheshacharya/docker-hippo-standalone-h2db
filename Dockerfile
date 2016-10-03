# Generic Hippo Docker image
FROM ubuntu:14.04
MAINTAINER Mahesh Acharya <m.acharya@onehippo.com>

# Set environment variables
ENV PATH /opt/tomcat/bin:$PATH
ENV TOMCAT_VERSION 8.0.37
ENV HIPPO_FILE gameday-project-0.1.0-SNAPSHOT-distribution.zip
ENV HIPPO_FOLDER gameday-project-0.1.0-SNAPSHOT-distribution
ENV HIPPO_URL https://s3.amazonaws.com/hippo-connect/gameday-project-0.1.0-SNAPSHOT-distribution.zip

#Tomcat Configurations for Hippo CMS
ENV HIPPO_TOMCAT_CONFIG apache-tomcat-${TOMCAT_VERSION}-hippo-simple-config
ENV HIPPO_TOMCAT_CONFIG_URL https://s3.amazonaws.com/achxis/docker/hippo-config/${HIPPO_TOMCAT_CONFIG}.zip 



# Create the work directory for Hippo
RUN mkdir -p /opt/tomcat

# Add Oracle Java Repositories
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:webupd8team/java
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Approve license conditions for headless operation
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

# Install packages required to install Hippo CMS
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-set-default
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dos2unix
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y unzip

#INSTALL TOMCAT
# Get Tomcat
RUN wget --quiet --no-cookies http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
tar xzvf /tmp/tomcat.tgz -C /opt 
RUN cp -r /opt/apache-tomcat-${TOMCAT_VERSION}/* /opt/tomcat/
RUN rm /tmp/tomcat.tgz && \
rm -rf /opt/tomcat/webapps/examples && \
rm -rf /opt/tomcat/webapps/docs && \
rm -rf /opt/tomcat/webapps/ROOT

RUN wget http://download.nextag.com/apache/tomcat/tomcat-8/v8.0.37/bin/apache-tomcat-8.0.37.zip -O /opt/tomcat.zip


# Add admin/admin user
#ADD tomcat-users.xml /opt/tomcat/conf/

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin


# Install Hippo CMS, retrieving the GoGreen demonstration from the $HIPPO_URL and putting it under $HIPPO_FOLDER
RUN curl -L $HIPPO_URL -o $HIPPO_FILE
RUN unzip $HIPPO_FILE -d $HIPPO_FOLDER
#RUN tar -xzf $HIPPO_FILE
RUN cp -r $HIPPO_FOLDER/* /opt/tomcat/
RUN chmod 700 /opt/tomcat/* -R

#Download Hippo Tomcat Configuration
RUN wget --quiet --no-cookies ${HIPPO_TOMCAT_CONFIG_URL} -O /tmp/${HIPPO_TOMCAT_CONFIG}.zip
RUN unzip /tmp/${HIPPO_TOMCAT_CONFIG} -d /tmp/


RUN cp -r /tmp/${HIPPO_TOMCAT_CONFIG}/bin/ /opt/tomcat/
RUN cp -r /tmp/${HIPPO_TOMCAT_CONFIG}/common /opt/tomcat/
RUN cp -r /tmp/${HIPPO_TOMCAT_CONFIG}/conf/ /opt/tomcat/



# Replace DOS line breaks on Apache Tomcat scripts, to properly load JAVA_OPTS
#RUN dos2unix /opt/tomcat/bin/setenv.sh
#RUN dos2unix /opt/tomcat/bin/catalina.sh

# Expose ports
EXPOSE 8080

# Start Hippo
WORKDIR /opt/tomcat/
CMD ["catalina.sh", "run"]
