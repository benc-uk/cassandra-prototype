node('dood') {
    container('dind') {
        stage('Build My Docker Image') {
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