node {

    stage("Git Clone"){

        git credentialsId: 'Git', url: 'https://github.com/NguyenTienHCL/kubernetes-full-stack-example.git'
    }

    stage("Docker build"){
        sh 'docker version'

        dir ("spring-boot-student-app-api"){
            sh 'mvn install'
        }

        dir ("react-student-management-web-app"){
            sh 'docker build -t tiennguyenhcl/student-app-client .'
        }
    }

    withCredentials([string(credentialsId: 'Docker', variable: 'PASSWORD')]) {
        sh 'docker login -u tiennguyenhcl -p $PASSWORD'
    }

    stage("Push Image to Docker Hub"){
        dir ("spring-boot-student-app-api"){
            sh 'mvn dockerfile:push'
        }
        sh 'docker push tiennguyenhcl/student-app-client'
    }
    stage("Add repo"){
        sh 'helm repo add prometheus-community https://prometheus-community.github.io/helm-charts'
        sh 'helm repo add bitnami https://charts.bitnami.com/bitnami'
    }
    stage("Deployment"){
        sh 'helm delete poc'
        sh 'helm install poc helm-chart/'
       
        sh 'helm install prometheus prometheus-community/prometheus'
        sh 'kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np'
        sh 'minikube service prometheus-server-np'

        sh 'helm install grafana bitnami/grafana'
        sh 'kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np'
        sh 'minikube service grafana-np'
    }
}
