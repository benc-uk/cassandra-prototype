  
/*
“Docker-outside-of-Docker”: runs a Docker-based build by connecting a Docker client inside the pod to the host daemon.
*/
podTemplate(yaml: """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:1.11
    command: ['cat']
    tty: true
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  volumes:
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
"""
  ) {

  node(POD_LABEL) {
    stage('Go get') {
        agent {
            docker { image 'golang:1.15-buster' }
        }
        steps {
            sh 'go get -u golang.org/x/lint/golint'
        }
    }
  }
}