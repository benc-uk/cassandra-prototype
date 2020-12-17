pipeline {
  agent {
    label 'vmagent'
  }
  parameters {
    string(name: 'imageTag', defaultValue: 'latest', description: 'Image tage to be deployed')
  }

  environment {
    DOCKER_REG   = 'ghcr.io'
    DOCKER_REPO  = 'benc-uk/cassandra-prototype'
  }

  stages {
    stage('helm-deploy') {
      agent {
        docker {
          image 'dtzar/helm-kubectl'
          args '-u root:root'
        }
      } 
      steps {
        sh 'helm repo add stable https://charts.helm.sh/stable'
        sh 'helm dep update kubernetes/helm/cassandra-go-api'
        sh 'helm upgrade --install app \
          kubernetes/helm/cassandra-go-api \
          --namespace proto-test \
          --values kubernetes/helm/app-values.yaml \
          --set "image.reg=$DOCKER_REG,image.repo=$DOCKER_REPO,image.tag=$imageTag,ingress.hosts[0].host=dave,ingress.tls[0].hosts[0]=dave"'
      }
    }
  }
}