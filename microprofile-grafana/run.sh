#!/bin/bash

export JSONNET_FILE=$PWD/dashboards/microprofile.jsonnet
export JSONNET_LIB=$PWD/grafonnet-lib
export JSONNET_BIN=$PWD/jsonnet

env|grep JSON

npm start
