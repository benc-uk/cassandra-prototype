pipeline {
  agent {
    label 'vmagent'
  }

  environment {
    DOCKER_REG   = 'ghcr.io'
    DOCKER_REPO  = 'benc-uk/cassandra-prototype'
    DOCKER_TAG   = sh (returnStdout: true, script: 'date +%d-%m-%Y.%H%M').trim()
    DOCKER_CREDS  = credentials('github-benc-uk-pat')
  }

  stages {
    stage('check-code') {
      agent {
        docker {
          image 'golang:1.15-buster'
          args '-u root:root'
        }
      } 
      steps {
        sh 'go get -u golang.org/x/lint/golint'
        sh 'go get gotest.tools/gotestsum'
        sh 'make format lint'
      }
    }

    stage('build') {
      steps {
        sh 'make build'
      }
    }

    stage('push') {
      when{
        branch 'main'
      }      
      steps {
        sh 'echo $DOCKER_CREDS_PSW | docker login ghcr.io -u $DOCKER_CREDS_USR --password-stdin'
        sh 'make push'
      }
    }

    stage('deploy') {
      when{
        branch 'main'
      }      
      steps {
        build job: 'deploy-to-aks', parameters: [string(name: 'imageTag', value: "${DOCKER_TAG}")]
      }
    }         
  }
}