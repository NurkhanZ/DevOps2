## nginx + PostgreSQL deployment on Minikube
### Prerequisites: minikube, kubectl, docker, virtualbox. 
### Tested on Arch Linux.
### Steps to run this project:
1. run minikube: minikube start --driver=virtualbox --nodes=3 --cpus=2 --memory=3072
2. install helm: pacman -S helm
3. install traefik: helm repo add traefik https://traefik.github.io/charts
                    helm repo update
                    helm install traefik --namespace kube-system traefik/traefik
4. apply manifests in folowing order: kubectl apply -f postgres-deployment.yaml
                                      kubectl apply -f nginx-deployment.yaml
                                      kubectl apply -f ingress.yaml
                                      kubectl apply -f network-policies.yaml
5. run in another terminal: minikube tunnel to get external ip of the load balancer
6. add entry: {"EXTERNAL IP" pq-django.test} without curly braces to a /etc/hosts file.
7. enter http://pq-django.test in the browser    

### How manifests works:
#### postgres-deployment.yaml: 
       create namespace web-app 
    -> create postgres-secret in web-app ns
    -> create postgres-deployment with label app=postgres and secret in web-app ns
    -> define inner container security restricting superuser access and privilege escalation
    -> create postgres-service with label app=postgres in web-app ns
#### nginx-deployment
       create nginx-deployment with label app=nginx in web-app ns
    -> create nginx-service with label app=nginx in web-app ns
#### ingress.yaml
       create Ingress using traefik ingress controller and to get trafic to host name pq-nginx.test
#### network-policies.yaml
       create defautl-deny-all policy for Ingress, Egress
    -> create allow-dns policy to allow CoreDNS communtication
    -> create allow-traefik-to-nginx policy for Ingress
    -> create allow-nginx-to-postgres policy for Ingress
    -> create allow-restrict-postgres policy

### Communication scheme:
       Web browser:80 -> traefik LoadBalancer:80 -> ingress -> nginx-service:80 -> nginx-deployment:8080  -> postgres-service:5432 -> postgres-deployment:5432 use postgres pod or stateful set
