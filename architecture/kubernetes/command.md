```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```



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