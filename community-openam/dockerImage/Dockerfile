FROM tomcat:8.5-jre8

LABEL author="Gonzalo Camino <gonzalo.camino@mulesoft.com>"

ENV OPENAM_HOST="openam.example.com"
ENV OPENAM_PORT="8443"
ENV OPENAM_ADMIN_PASSWORD="Anypoint1379"
ENV OPENAM_VERSION="14.5.1"
ENV CATALINA_HOME="/usr/local/tomcat"
ENV PATH $CATALINA_HOME/bin:$PATH
ENV OPENAM_USER="openam"
ENV OPENAM_DATA_DIR="/usr/openam/config"
ENV CATALINA_OPTS="-Xmx2048m -server -Dcom.iplanet.services.configpath=${OPENAM_DATA_DIR} -Dcom.sun.identity.configuration.directory=${OPENAM_DATA_DIR}"
ENV TLS_KEYSTORE_FILE="${CATALINA_HOME}/conf/keystore"
ENV TLS_KEYSTORE_ALIAS="tomcat"
ENV TLS_KEYSTORE_PASSWORD="password"

WORKDIR ${CATALINA_HOME}

# Configire SSL

#RUN keytool -genkey -noprompt \
#    -alias ${TLS_KEYSTORE_ALIAS} \
#    -dname "CN=${OPENAM_HOST}, OU=GSET, O=MuleSoft, L=San Francisco, S=Calidornia, C=US" \
#    -keystore ${TLS_KEYSTORE_FILE} \
#    -storepass ${TLS_KEYSTORE_PASSWORD} \
#    -keypass ${TLS_KEYSTORE_PASSWORD} \
#    -keyalg RSA \
#    -keysize 4096 \
#    -validity 720

#RUN keytool -export -keystore ${TLS_KEYSTORE_FILE} -alias ${TLS_KEYSTORE_ALIAS} -file /tmp/tomcat.cer
#RUN keytool -import -noprompt -trustcacerts -alias ${TLS_KEYSTORE_ALIAS} -file /tmp/tomcat.cer -keystore /tmp/cacerts.jks -keypass ${TLS_KEYSTORE_PASSWORD} -storepass ${TLS_KEYSTORE_PASSWORD}
#RUN chmod 644 /tmp/tomcat.cer

# enable HTTPS on Tomcat
RUN perl -0pi.bak -e 's/<!--\n    <Connector port="8443"/<Connector port="'"${OPENAM_PORT}"'" keystoreFile="\/usr\/local\/tomcat\/conf\/keystore" keystorePass="'"${TLS_KEYSTORE_PASSWORD}"'" keyAlias="'"${TLS_KEYSTORE_ALIAS}"'" sslProtocol="TLS"/' ${CATALINA_HOME}/conf/server.xml
RUN perl -0pi.bak -e 's/<SSLHostConfig>\n            <Certificate certificateKeystoreFile="conf\/localhost-rsa.jks"\n                         type="RSA" \/>\n        <\/SSLHostConfig>\n    <\/Connector>\n    -->/<\/Connector>/' ${CATALINA_HOME}/conf/server.xml

# Install OpenAM
RUN wget --show-progress --progress=bar:force:noscroll --quiet https://github.com/OpenIdentityPlatform/OpenAM/releases/download/${OPENAM_VERSION}/OpenAM-${OPENAM_VERSION}.war
RUN mv *.war ${CATALINA_HOME}/webapps/openam.war

RUN mkdir /usr/openam

RUN chgrp -R 0 /usr/openam/ && \
  chmod -R g=u /usr/openam/

RUN chgrp -R 0 /usr/local/tomcat && \
  chmod -R g=u /usr/local/tomcat

RUN useradd -m -r -u 1001 -g root ${OPENAM_USER} \
    && install -d -o ${OPENAM_USER} ${OPENAM_DATA_DIR}

# Copy init script and configuratino file
COPY openaminit.sh /tmp
RUN chmod 700 /tmp/openaminit.sh
RUN chown ${OPENAM_USER} /tmp/openaminit.sh
COPY config.properties /tmp
RUN chown ${OPENAM_USER} /tmp/config.properties
RUN chmod 644 /tmp/config.properties

# Download required artifacts
USER ${OPENAM_USER}

RUN wget --show-progress --progress=bar:force:noscroll --quiet --output-document=/usr/openam/ssoconfiguratortools.zip https://github.com/OpenIdentityPlatform/OpenAM/releases/download/${OPENAM_VERSION}/SSOConfiguratorTools-${OPENAM_VERSION}.zip \
 && unzip /usr/openam/ssoconfiguratortools.zip -d /usr/openam/ssoconfiguratortools \
 && rm /usr/openam/ssoconfiguratortools.zip

RUN wget --show-progress --progress=bar:force:noscroll --quiet --output-document=/usr/openam/ssoadmintools.zip https://github.com/OpenIdentityPlatform/OpenAM/releases/download/${OPENAM_VERSION}/SSOAdminTools-${OPENAM_VERSION}.zip \
 && unzip /usr/openam/ssoadmintools.zip -d /usr/openam/ssoadmintools \
 && rm /usr/openam/ssoadmintools.zip

# Create a configuration file

# Finally
ENTRYPOINT ["/tmp/openaminit.sh"]