FROM golang:1.15-buster

RUN apt-get update && apt-get install -y lsb-release software-properties-common

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
 && apt-get update \
 && apt-get install docker-ce-cli

RUN go get -u golang.org/x/lint/golint \
 && go get gotest.tools/gotestsum

RUN apt-get clean autoclean \
 && apt-get autoremove --yes \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/