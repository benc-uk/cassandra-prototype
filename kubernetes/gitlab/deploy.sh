helm repo add gitlab https://charts.gitlab.io/
helm install gitlab gitlab/gitlab -n gitlab -f ./values.yaml