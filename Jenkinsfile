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
            sh 'docker build -t tiennguyenhcl/student-app-client:1.0.4 .'
        }
    }

    withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'dockerhubpwd')]) {
            sh 'docker login -u tiennguyenhcl -p ${dockerhubpwd}'
    }

    stage("Push Image to Docker Hub"){
        dir ("spring-boot-student-app-api"){
            sh 'mvn dockerfile:push'
        }
        sh 'docker push tiennguyenhcl/student-app-client:1.0.4'
    }
}
