# Minikube
Minikube is a tool that allows you to run Kubernetes locally by creating a single node cluster on your local machine. It requires atleast 2 gb ram and 2 cpu cores.

# Kubeadm
Kubeadm is a generic tool which can run multi node cluster on physical machines or VMs. You can **kubeadm init** to bootstrap the master node. And, then **kubeadm join** to join other nodes.
It requires atleast 2 gb ram and 2 cpu cores for the master node. And, worker nodes require atleast 1 gb ram and 1 cpu cores.

# KOPS
kops helps you create, destroy, upgrade and maintain production-grade, highly available, Kubernetes clusters from the command line. AWS (Amazon Web Services) is currently officially supported, with GCE and OpenStack in beta support, and VMware vSphere in alpha, and other platforms planned.
If you are not planning to use AKS or GKE, then you should use KOPS to deploy and manage kubernetes cluster.
Features:
- Automates the provisioning of Kubernetes clusters in AWS, OpenStack and GCE
- Deploys Highly Available (HA) Kubernetes Masters
- Ability to generate Terraform
- Built on a state-sync model for dry-runs and automatic idempotency and many more

# Kind
Kind is another tool to deploy a Kubernetes cluster locally. Its specificity is that the cluster will be deployed inside multiple Docker containers.

# K3S
It is lightweight alternative to kubeadm, developed by Rancher. It requires 1/4 memory and cpu required by kubeadm.