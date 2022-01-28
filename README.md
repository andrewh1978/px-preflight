# What

This will provision some objects on your Kubernetes cluster, use them to run some basic checks add put the results as yaml into a configmap. Checks include:
 * CPU cores
 * Kernel version
 * RAM
 * /var space
 * /opt space
 * Network connectivity between all worker nodes in the defined port range
 * Ping latency
 * Block devices

# How

1. Ensure your Kubernetes cluster is up and running:
```
[root@master-1 ~]# kubectl get nodes
NAME       STATUS   ROLES    AGE     VERSION
master-1   Ready    master   5h59m   v1.16.2
node-1-1   Ready    <none>   5h58m   v1.16.2
node-1-2   Ready    <none>   5h58m   v1.16.2
node-1-3   Ready    <none>   5h58m   v1.16.2
```

2. Clone this repo:
```
[root@master-1 px-preflight]# git clone https://github.com/andrewh1978/px-preflight
Cloning into 'px-preflight'...
remote: Enumerating objects: 63, done.
remote: Counting objects: 100% (63/63), done.
remote: Compressing objects: 100% (47/47), done.
remote: Total 63 (delta 29), reused 50 (delta 16), pack-reused 0
Unpacking objects: 100% (63/63), done.
```

3. Build the image:
```
[root@master-1 px-preflight]# docker build -t px-preflight .
...
```
This image will need pushing to your registry.

Alternatively, there is a script to build the image and load it on each node:
```
[root@master-1 px-preflight]# sh distribute_image.sh
...
```

4. Configure:
```
[root@master-1 ~]# cd px-preflight
[root@master-1 px-preflight]# vi px-preflight.yml
```
Find the ConfigMap called `config`.
 * Configure the port range with `START_PORT` and `END_PORT`
 * The default `MIN` and `MAX` thresholds should be fine for most use-cases

5. Run:
```
[root@master-1 px-preflight]# kubectl apply -f px-preflight.yml
namespace/px-preflight created
configmap/config created
serviceaccount/px-preflight-sa created
role.rbac.authorization.k8s.io/px-preflight-role created
rolebinding.rbac.authorization.k8s.io/px-preflight-rb created
clusterrole.rbac.authorization.k8s.io/px-preflight-cr unchanged
clusterrolebinding.rbac.authorization.k8s.io/px-preflight-crb unchanged
deployment.apps/postgres created
service/postgres created
configmap/env created
configmap/files created
job.batch/initdb created
job.batch/one created
daemonset.apps/many created
```

6. View the results:
```
[root@master-1 px-preflight]# kubectl get configmap -n px-preflight output -o jsonpath='{.data.results}'
[root@master-1 px-preflight]# kubectl get configmap -n px-preflight output -o jsonpath='{.data.failures}'
```

# TODO

 * populate etcd_nodes
 * test etcd if external
 * test cloud creds
