#!/bin/bash
OPENAM_CONFIG_DIR="/usr/openam/config"
# Create TLS Certificate
TMP_TOMCAT_CER="/tmp/tomcat.cer"
TMP_TOMCAT_JKS="/tmp/cacerts.jks"
keytool -genkey -noprompt -alias ${TLS_KEYSTORE_ALIAS} -dname "CN=${OPENAM_HOST}, OU=GSET, O=MuleSoft, L=San Francisco, S=Calidornia, C=US" -keystore ${TLS_KEYSTORE_FILE} -storepass ${TLS_KEYSTORE_PASSWORD} -keypass ${TLS_KEYSTORE_PASSWORD} -keyalg RSA -keysize 4096 -validity 720
keytool -export -keystore ${TLS_KEYSTORE_FILE} -alias ${TLS_KEYSTORE_ALIAS} -file ${TMP_TOMCAT_CER} -storepass ${TLS_KEYSTORE_PASSWORD}
keytool -import -noprompt -trustcacerts -alias ${TLS_KEYSTORE_ALIAS} -file ${TMP_TOMCAT_CER} -keystore ${TMP_TOMCAT_JKS} -keypass ${TLS_KEYSTORE_PASSWORD} -storepass ${TLS_KEYSTORE_PASSWORD}
# if this is the first boot, configure OpenAM, if not reuse existing configuration
if [ "$(ls -1p ${OPENAM_CONFIG_DIR} 2>/dev/null | grep -v 'lost+found' | wc -l)" -eq 0 ]
then
    # Start Tomcat to execute config tool
    ${CATALINA_HOME}/bin/startup.sh
    sleep 30
    echo "SERVER_URL=https://${OPENAM_HOST}:${OPENAM_PORT}" >> /tmp/openamconfig.properties
    echo "DIRECTORY_SERVER=${OPENAM_HOST}" >> /tmp/openamconfig.properties
    echo "BASE_DIR=${OPENAM_CONFIG_DIR}" >> /tmp/openamconfig.properties
    echo "ADMIN_PWD=${OPENAM_ADMIN_PASSWORD}" >> /tmp/openamconfig.properties
    HASH="$(date +%s | md5sum | cut -d" " -f1)"
    echo "AMLDAPUSERPASSWD=${HASH}" >> /tmp/openamconfig.properties
    echo "DS_DIRMGRPASSWD=${HASH}" >> /tmp/openamconfig.properties
    cat /tmp/config.properties >> /tmp/openamconfig.properties
    java -Djavax.net.ssl.trustStore=${TMP_TOMCAT_JKS} -Djavax.net.ssl.trustStorePassword=password -jar /usr/openam/ssoconfiguratortools/openam-configurator-tool-${OPENAM_VERSION}.jar --file /tmp/openamconfig.properties
    ${CATALINA_HOME}/bin/shutdown.sh
    sleep 30
fi
${CATALINA_HOME}/bin/catalina.sh run