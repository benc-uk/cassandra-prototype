pipeline {
  //agent any
  agent {
      docker {
          image 'golang:1.15.6-buster'
          label '1.15.6-buster'
      }
  }
  stages {
    stage('check') {
      // Hello
      steps {
        sh 'make format lint'
      }
    }
  }
}