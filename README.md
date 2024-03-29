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
 * etcd connectivity

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
[root@master-1 ~]# git clone https://github.com/andrewh1978/px-preflight
Cloning into 'px-preflight'...
remote: Enumerating objects: 63, done.
remote: Counting objects: 100% (63/63), done.
remote: Compressing objects: 100% (47/47), done.
remote: Total 63 (delta 29), reused 50 (delta 16), pack-reused 0
Unpacking objects: 100% (63/63), done.
```

3. Build the image:
```
[root@master-1 ~]# cd px-preflight
[root@master-1 px-preflight]# docker build -t andrewh1978/px-preflight .
...
```

4. Push the image to your registry:
```
[root@master-1 px-preflight]# docker login registry-1.docker.io
[root@master-1 px-preflight]# docker push andrewh1978/px-preflight
...
```

5. Configure:
```
[root@master-1 px-preflight]# vi px-preflight.yml
```
Find the ConfigMap called `config`.
 * Configure the port range with `START_PORT` and `END_PORT`
 * Adjust the node filter
 * The default `MIN` and `MAX` thresholds should be fine for most use-cases
 * Uncomment and edit `ETCD_ENDPOINTS` if using external etcd
Also update the `image` parameters (if necessary).

6. Run:
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

7. After a short time, you should be able to view the results:
```
[root@master-1 px-preflight]# kubectl get configmap -n px-preflight output -o jsonpath='{.data.results}'
[root@master-1 px-preflight]# kubectl get configmap -n px-preflight output -o jsonpath='{.data.failures}'
```

# TODO

 * test cloud creds
