# Basic Kubectl Commands

### Get version of kubectl and kubernetes
```sh
kubectl version 
#Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.2", GitCommit:"092fbfbf53427de67cac1e9fa54aaa09a28371d7", GitTreeState:"clean", BuildDate:"2021-06-16T12:59:11Z", GoVersion:"go1.16.5", Compiler:"gc", Platform:"windows/amd64"}
#Server Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.1", GitCommit:"5e58841cce77d4bc13713ad2b91fa0d961e69192", GitTreeState:"clean", BuildDate:"2021-05-12T14:12:29Z", GoVersion:"go1.16.4", Compiler:"gc", Platform:"linux/amd64"}
```

### Get cluster Info such as Control Plane and CoreDNS endpoint
```sh
kubectl cluster-info
#Kubernetes control plane is running at https://kubernetes.docker.internal:6443
#CoreDNS is running at https://kubernetes.docker.internal:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

```

### Get detail of any resource in kubernetes
```sh
kubectl get <pods/nodes/services/namespaces/deployments/...>
```

### Get detailed description of any resource in kubernetes
```sh
kubectl describe <pods/nodes/services/namespaces/deployments/...>
```

### To create and deploy kubernetes dashboard pod 
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```


### To expose kubernetes api to external world through proxy
```
kubectl proxy
```

Kubectl will make Dashboard available at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.



The UI can *only* be accessed from the machine where the command is executed. See `kubectl proxy --help` for more options.



### Create the dashboard service account

```bash
kubectl create serviceaccount dashboard-admin-sa
```

This will create a service account named dashboard-admin-sa in the default namespace

Next bind the dashboard-admin-service-account service account to the cluster-admin role

```bash
kubectl create clusterrolebinding dashboard-admin-sa 
--clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
```

When we created the dashboard-admin-sa service account Kubernetes also created a secret for it.



List secrets using:

```bash
kubectl get secrets
```

![kubectl-get-secrets-kubernetes-dashboard](https://www.replex.io/hs-fs/hubfs/Blog%20images/kubectl-get-secrets-kubernetes-dashboard.png?width=749&name=kubectl-get-secrets-kubernetes-dashboard.png)

We can see the dashboard-admin-sa service account secret in the above screenshot above.

Use kubectl describe to get the access token:

```bash
kubectl describe secret dashboard-admin-sa-token-kw7vn
```

![kubectl-describe-secret-kubernetes-dashboard](https://www.replex.io/hs-fs/hubfs/Blog%20images/kubectl-describe-secret-kubernetes-dashboard.png?width=1086&name=kubectl-describe-secret-kubernetes-dashboard.png)

Copy the token and enter it into the token field on the Kubernetes dashboard login page.