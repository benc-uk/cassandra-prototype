pipeline {
  agent {
    docker { 
      image 'golang:1.15-alpine'
      args '-u root:root'
    }
  }
  stages {
    stage('check-code') {
      steps {
        sh 'go get -u golang.org/x/lint/golint'
        sh 'go get gotest.tools/gotestsum'
        sh 'make format lint'
        sh 'make test'
      }
    }
  }
}