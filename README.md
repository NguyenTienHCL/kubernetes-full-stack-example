# POC  Level 1
## _Step 1: Launch Instances_
- Instance type: t2.xlarge
- Open all traffic port in Security Group
- Select storage of 16GiB

## _Step 2: Installation_
### Jenkins 
`v2.346.2`

	sudo apt-get update -y
	wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
	sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get update
	sudo apt-get install jenkins

### Java
`v11.0.15`

	sudo apt install openjdk-11-jre

### Maven
`v3.6.3`

	sudo apt install maven

### Git
`v2.34.1`

	sudo apt install git

### Docker
`v20.10.17`

	sudo apt update
	sudo apt install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	apt-cache policy docker-ce
	sudo apt install docker-ce
	sudo systemctl status docker
	sudo usermod -aG docker ${USER}

### Helm
`v3.9.2`

	curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
	sudo apt-get install apt-transport-https --yes
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
	sudo apt-get update
	sudo apt-get install helm

### Minikube
`v1.26.0` 

	sudo apt-get update -y
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
	sudo dpkg -i minikube_latest_amd64.deb

### Kubelet
`Client version 1.24.3`
`Server version 1.23.8`

	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes release/release/stable.txt`/bin/linux/amd64/kubectl
	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin/kubectl
	kubectl version -o json

## _Step 3: Configuration_
### GitHub
- Create webhook

![](https://github.com/NguyenTienHCL/POC-L1/blob/main/MicrosoftTeams-image%20(3).png)

- Create Trigger

![](https://github.com/NguyenTienHCL/POC-L1/blob/main/MicrosoftTeams-image%20(2).png)

### Jenkins

- Access port 8080

![](https://github.com/NguyenTienHCL/POC-L1/blob/main/MicrosoftTeams-image%20(1).png)

- Get Jenkins password

`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

- Move on PATH

`manage jenkins/manage plugins/available` 
--> Install ssh pipeline steps, maven intergration, kubernetes CLI, kubernetes

`manage jenkins/ global tool configuration/` 
--> Add PATH of java and maven

`manage jenkins/ manage credentials` 
--> Add GitHub account and Dockerhub password to assign to Jenkins pipeline

- Write Jenkinsfile on GitHub

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
					sh 'docker build -t tiennguyenhcl/student-app-client:1.0.2 .'
				}
			}

			withCredentials([string(credentialsId: 'Docker', variable: 'PASSWORD')]) {
				sh 'docker login -u tiennguyenhcl -p $PASSWORD'
			}

			stage("Push Image to Docker Hub"){
				dir ("spring-boot-student-app-api"){
					sh 'mvn dockerfile:push'
				}
				sh 'docker push tiennguyenhcl/student-app-client:1.0.2'
			}
			stage("Add repo"){
				sh 'helm repo add prometheus-community https://prometheus-community.github.io/helm-charts'
				sh 'helm repo add bitnami https://charts.bitnami.com/bitnami'
				sh 'helm repo add istio https://istio-release.storage.googleapis.com/charts'
				sh 'helm repo update'
			}

			stage("Deployment istio"){
				// sh 'kubectl create namespace istio-system'
				sh 'helm upgrade istio-base istio/base -n istio-system --install'
				sh 'helm upgrade istiod istio/istiod -n istio-system --wait --install'
				// sh 'kubectl create namespace istio-ingress'
				sh 'kubectl label namespace default istio-injection=enabled --overwrite'
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
		//         sh 'kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np'
		//         sh 'minikube service prometheus-server-np'
			}     
			stage("Deployment graffana"){
				sh 'helm upgrade grafana bitnami/grafana --install'
		//         sh 'kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np'
		//         sh 'echo "Password: $(kubectl get secret grafana-admin --namespace default -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 -d)"'
		//         sh 'minikube service grafana-np'
			}
		}

### Kubernetes

- Create connection with Kubernetes

		sudo cp -r .kube/ .minikube/ /var/lib/jenkins/
		sudo chown -R jenkins /var/lib/jenkins/.minikube/ /var/lib/jenkins/.kube/
		sudo nano /var/lib/jenkins/.kube/config 

- Modify the PATH: /home/ubuntu --> /var/lib/jenkins/

		apiVersion: v1
		clusters:
		- cluster:
			certificate-authority: /var/lib/jenkins/.minikube/ca.crt
			extensions:
			- extension:
				last-update: Mon, 18 Jul 2022 04:55:53 UTC
				provider: minikube.sigs.k8s.io
				version: v1.26.0
			  name: cluster_info
			server: https://10.0.0.94:8443
		  name: minikube
		contexts:
		- context:
			cluster: minikube
			extensions:
			- extension:
				last-update: Mon, 18 Jul 2022 04:55:53 UTC
				provider: minikube.sigs.k8s.io
				version: v1.26.0
			  name: context_info
			namespace: default
			user: minikube
		  name: minikube
		current-context: minikube
		kind: Config
		preferences: {}
		users:
		- name: minikube
		  user:
			client-certificate: /var/lib/jenkins/.minikube/profiles/minikube/client.crt
			client-key: /var/lib/jenkins/.minikube/profiles/minikube/client.key

-  Log in jenkins

	+ Change the PATH according to jenkins PATH (/home/ubuntu/ -> /var/lib/jenkins/ ) 

	+ Test connection: `manage jenkins/ manage nodes and clouds` -> Select Kubernetes 

### Docker

- Start docker `sudo service docker start`

- Get permission to run docker cmd `sudo usermod -aG docker jenkins` 

### Helm
- Create helm chart `helm create <name>`

- Modify directory templates and file values.yaml 

		pvc:
		  name: mongo-pvc
		  storage: 256Mi

		mongo:
		  name: mongo
		  port: 27017
		  image: mongo:3.6.17-xenial
		  namevol: storage
		  path: /data/db

		api:
		  name: student-app-api
		  port: 8080
		  protocol: TCP
		  type: ClusterIP
		  image: tiennguyenhcl/student-app-api:0.0.1-SNAPSHOT
		  policy: Always
		  replicas: 1
		  env:
			name: MONGO_URL
			value: mongodb://mongo:27017/dev

		client:
		  name: student-app-client
		  port: 80
		  protocol: TCP
		  type: ClusterIP
		  image: tiennguyenhcl/student-app-client:1.0.2
		  policy: Always
		  replicas: 1

		ingress:
		  name: student-app-ingress
		  path1: /?(.*)
		  path2: /api/?(.*)
		  type: Prefix

- Create one more file `istio_ingress.yaml` to creat GATEWAY and VIRTUAL SERVICE 
--> Connect microservice and get permission to connect outside

		apiVersion: networking.istio.io/v1alpha3
		kind: Gateway
		metadata:
		  name: tien-gateway
		spec:
		  selector:
			istio: ingress
		  servers:
		  - port: 
			  number: 80
			  name: http
			  protocol: HTTP
			hosts:
			- "*"
		---
		apiVersion: networking.istio.io/v1alpha3
		kind: VirtualService
		metadata:
		  name: tien-ingress
		spec:
		  hosts:
			- "*"
		  gateways:
			- gateway
		  http:
			- match:
			  - uri:
				  prefix: '/api'
			  rewrite:
				uri: '/'
			  route:
			  - destination:
				  host: student-app-api.default.svc.cluster.local
				  port:
					number: 8080
			- route:
			  - destination:
				  host: student-app-client.default.svc.cluster.local
				  port:
					number: 80

### Minikube + kubectl

- Start Minikube `minikube start --driver=none --kubernetes-version v1.23.8`

- Allow external access to services in a cluster `minikube addons enable ingress`

- Create namespace:

		kubectl create namespace istio-system
		kubectl create namespace istio-ingress

### Deployment

- Build job in jenkins

- Verify connect the cluster with kubectl CLI and list all namespaces, pods and services

		kubectl get all -A
![](https://github.com/NguyenTienHCL/POC-L1/blob/main/MicrosoftTeams-image%20(4).png)

		helm list
![](https://github.com/NguyenTienHCL/POC-L1/blob/main/MicrosoftTeams-image%20(5).png)

- Create a Service object that exposes the deployment

		kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np
		minikube service prometheus-server-np

		kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np
		minikube service grafana-np

- Get Grafana's password admin

		echo "Password: $(kubectl get secret grafana-admin --namespace default -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 -d)"

- In order to update title in file `kubernetes-full-stack-example/react-student-management-web-app/src/App.js`

		git clone <...>
		//make changes tag name of images in file (values.yaml, Jenkinsfile)
		git add .
		git commit -m "..."
		git push
