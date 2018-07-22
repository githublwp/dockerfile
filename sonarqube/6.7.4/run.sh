#!/bin/bash

keytool -import -v -trustcacerts -alias sonar -file /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/tls.crt -storepass changeit -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts <<EOF
y
EOF

if [ ! -d "/opt/sonarqube/extensions/plugins/" ];then
mkdir /opt/sonarqube/extensions/plugins
else
echo "dir is exists!"
fi
cp /opt/sonarqube/sonar-auth-oidc-plugin-1.0.4.jar /opt/sonarqube/extensions/plugins/

set -e

if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

chown -R sonarqube:sonarqube $SONARQUBE_HOME
exec gosu sonarqube \
  java -jar lib/sonar-application-$SONAR_VERSION.jar \
  -Dsonar.log.console=true \
  -Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
  -Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
  -Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
  -Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  "$@"
