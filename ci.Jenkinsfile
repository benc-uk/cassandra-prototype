pipeline {
  agent {
    docker { 
      // Blah
      image 'golang:1.15-buster'
      args '-u root:root'
      label 'dood'
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