#!/bin/bash
echo "d"

set -e
echo "e"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $DIR

# Args for the container
BASE=registry.access.redhat.com/ubi8/ubi-minimal:8.3
JAVA_PACKAGE=java-11-openjdk-headless
RUN_JAVA_VERSION=1.3.8

IMAGE_NAME=hello:latest
if [[ $1 ]]; then
  IMAGE_NAME=$1
fi

echo -e "\n☕ Running Maven build & package"
pushd $DIR/..
./mvnw package
popd

# Create a container
echo -e "\n💠 Creating new base container"
container=$(buildah from $BASE)

echo -e "\n💠 Main container build steps"
buildah run $container /bin/sh -c "microdnf install curl ca-certificates ${JAVA_PACKAGE}; \
  microdnf update; \
  microdnf clean all; \
  mkdir /deployments; \
  chown 1001 /deployments; \
  chmod g+rwX /deployments; \
  chown 1001:root /deployments; \
  curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /deployments/run-java.sh; \
  chown 1001 /deployments/run-java.sh; \
  chmod 540 /deployments/run-java.sh; \
  echo 'securerandom.source=file:/dev/urandom' >> /etc/alternatives/jre/lib/security/java.security"

buildah run $container java --version

echo -e "\n💠 Copy files from target dir"
buildah copy $container $DIR/../target/lib/* /deployments/lib/
buildah copy $container $DIR/../target/*-runner.jar /deployments/app.jar

echo -e "\n💠 Configuring container image options"
buildah config --env JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager" $container
buildah config --port 8080 $container
buildah config --user 1001 $container
buildah config --entrypoint "/deployments/run-java.sh" $container

echo -e "\n💠 Done! Saving image"
buildah commit --rm $container $IMAGE_NAME