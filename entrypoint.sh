#!/usr/bin/env bash

set -e

if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

# Parse Docker env vars to customize SonarQube
#
# e.g. Setting the env var sonar.jdbc.username=foo
#
# will cause SonarQube to be invoked with -Dsonar.jdbc.username=foo

declare -a sq_opts

while IFS='=' read -r envvar_key envvar_value
do
    if [[ "$envvar_key" =~ sonar.* ]]; then
        sq_opts+=("-D${envvar_key}=${envvar_value}")
    fi
done < <(env)

exec java -jar lib/sonar-application-$SONAR_VERSION.jar \
  -Dsonar.log.console=true \
  -Dsonar.jdbc.username="$SONAR_JDBC_USERNAME" \
  -Dsonar.jdbc.password="$SONAR_JDBC_PASSWORD" \
  -Dsonar.jdbc.url="$SONAR_JDBC_URL" \
  -Dsonar.web.javaAdditionalOpts="$SONAR_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  -Dsonar.search.javaAdditionalOpts="-Dbootstrap.system_call_filter=false -Dnode.store.allow_mmap=false" \
  "${sq_opts[@]}" \
  "$@"
