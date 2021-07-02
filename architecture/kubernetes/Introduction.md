# Basic Structure of Kubernetes

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEVZzZT1Hd3mA/article-inline_image-shrink_1000_1488/0/1609172049194?e=1630540800&v=beta&t=M2p4a0O8kWytpsBmsOY8vJx5CRXQvMg6jRODd7S31KU)



The basic structure of Kubernetes Cluster:

**Cluster**: A Kubernetes cluster is a set of node machines for running containerized applications. If you’re running Kubernetes, you’re running a cluster.

**Node**: A node is a worker machine on Kubernetes it could be either a Physical or Virtual device as per the Cluster.

How cluster works: Worker node run containerized applications. The worker node runs the pod that is the component of the application. Each cluster has a worker node.Cluster managers the all.



### User Interface for Kubernetes

**Kubectl**: It's a command-line tool that helps you to control - clusters.

**UI**: The user interface of Kubernetes Dashboard.

**API**: API is the end from where the user interacts with clusters.



### Master Node

The Kubernetes Master (Master Node) receives input from a CLI (Command-Line Interface) or UI (User Interface) via an API. These are the commands you provide to Kubernetes.

You define pods, replica sets, and services that you want Kubernetes to maintain. For example, which container image to use, which ports to expose, and how many pod replicas to run.

You also provide the parameters of the desired state for the application(s) running in that cluster.

**Scheduler**: A **Scheduler** watches for new requests coming from the API Server and assigns them to healthy nodes. It ranks the quality of the nodes and deploys pods to the best-suited node. If there are no suitable nodes, the pods are put in a pending state until such a node appears.

**API Server**:  The API Server is the front-end of the control plane and the only component in the control plane that we interact with directly. Internal system components, as well as external user components, all communicate via the same API. It configures the number of API object running in a cluster Which includes pods, nodes, replication controllers, services, etc. 

**Control Manager**: The role of the **Controller** is to obtain the desired state from the API Server. It checks the current state of the nodes it is tasked to control, and determines if there are any differences, and resolves them, if any.

**ETCD**: It is a distributed key-value store use to hold the critical information  such as application desired state.



### Worker Node

Worker nodes listen to the API Server for new work assignments; they execute the work assignments and then report the results back to the Kubernetes Master node.

**KubeProxy**: It's a network-based proxy that is run on your every cluster. It maintains the rules of the network to the nodes. It makes sure that each node gets its IP address, implements local *iptables* and rules to handle routing and traffic load-balancing.

**Kubelet**: It runs on every node in the cluster. It is the principal Kubernetes agent. By installing kubelet, the node’s CPU, RAM, and storage become part of the broader cluster. It watches for tasks sent from the API Server, executes the task, and reports back to the Master. It also monitors pods and reports back to the control panel if a pod is not fully functional. Based on that information, the Master can then decide how to allocate tasks and resources to reach the desired state.

**Container Runtime**: The **container runtime** pulls images from a **container image registry** and starts and stops containers. A 3rd party software or plugin, such as Docker, usually performs this function.



# Autoscaling methods for Kubernetes

### Horizontal Pod Autoscaler: "Scaling out"

With a Horizontal Pod Autoscaler, “a cluster operator declares their target usage for metrics, such as CPU or memory utilization, as well their desired maximum and minimum desired number of replicas, The cluster will then reconcile the number of replicas accordingly, and scale up or down the number of running pods based on their current usage and the desired target.”

### Vertical Pod Autoscaler: "Scaling up"

A Vertical Pod Autoscaler allows you to scale a given service vertically within a cluster. The cluster operator declares their target usage for metrics, such as CPU or memory utilization, similarly to a Horizontal Pod Autoscaler. The cluster will then reconcile the size of the service’s pod or pods based on their current usage and the desired target.

### Cluster Autoscaler

HPA and VPA essentially make sure that all of the services running in your cluster can dynamically handle demand while not over-provisioning during slower usage periods. That’s a good thing.

But there’s now another issue that needs to be addressed: “What happens when load is at a peak and the nodes in the cluster are getting too overloaded with all the newly scaled pods?” Cohen says.

This is where the Cluster Autoscaler goes to work: As the name indicates, it’s what allows for the autoscaling of the cluster itself, increasing and decreasing the number of [nodes ](https://www.kubernetesbyexample.com/en/concept/nodes?intcmp=701f2000000tjyaAAA)available for your pods to run on. (A node in Kubernetes lingo is a physical or virtual machine.)

“Based on current utilization, the Cluster Autoscaler will reach out to a cloud provider’s API and scale up or down the number of nodes attached to the cluster accordingly, and the pods will rebalance themselves across the cluster,



## Reap Benefits

In many cases, a combination of all three autoscaling methods will be used in a given environment to ensure that services can run in a stable way while at peak load, and while keeping costs to a minimum during times of lower demand,



# Cloud Service Provider

1. GKE (Google)
2. AKS (Azure)
3. EKS (Amazon)



Kustomization

Ingress

Service

Deployment

Pod

HPA

ConfigMap



