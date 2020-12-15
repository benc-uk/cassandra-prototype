pipeline {
  agent any
  // agent {
  //     docker {
  //         image 'golang'
  //         label '1.15.6-buster'
  //     }
  // }
  stages {
    stage('check') {
      steps {
        sh 'make format lint'
      }
    }
  }
}