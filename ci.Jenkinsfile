pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: dind-agent
spec:
  containers:
  - name: dind
    image: docker:19.03.11-dind
    imagePullPolicy: Always
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
      - name: docker-graph-storage
        mountPath: /var/lib/docker
  volumes:
    - name: docker-graph-storage
      emptyDir: {}
"""
    }
  }
  stages {
    stage('Build My Docker Image')  {
      steps {
        container('dind') {
            sh 'docker info'
            sh 'touch Dockerfile'
            sh 'echo "FROM centos:7" > Dockerfile'
            sh "cat Dockerfile"
            sh "docker -v"
            sh "docker info"
            sh "docker build -t my-centos:1 ."
        }
      }
    }
  }
}