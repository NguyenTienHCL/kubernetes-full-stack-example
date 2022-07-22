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
        sh 'helm repo add istio https://istio-release.storage.googleapis.com/charts'
        sh 'helm repo update'
    }
    
    stage("Deployment istio"){
        sh 'kubectl create namespace istio-system'
        sh 'helm upgrade istio-base istio/base -n istio-system --install'
        sh 'helm upgrade istiod istio/istiod -n istio-system --wait --install'
        sh 'kubectl create namespace istio-ingress'
        sh 'kubectl label namespace default istio-injection=enabled'
    }
    
    stage("Deployment react"){
//         sh 'minikube start --driver=none --kubernetes-version v1.23.8'
        sh 'helm upgrade poc helm-chart/ --install'
        dir("helm-chart"){
            sh 'kubectl apply -f istio_ingress.yaml'
        }
        sh 'helm upgrade istio-ingress istio/gateway -f ip-external.yaml --install'
    }
    
    stage("Deployment prometheus"){
        sh 'helm upgrade prometheus prometheus-community/prometheus --install'
        sh 'kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np'
//         sh 'minikube service prometheus-server-np'
    }     
    stage("Deployment graffana"){
        sh 'helm upgrade grafana bitnami/grafana --install'
        sh 'kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np'
//         sh 'echo "Password: $(kubectl get secret grafana-admin --namespace default -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 -d)"'
//         sh 'minikube service grafana-np'
    }
}
