docker save px-preflight -o px-preflight.tar

for i in $(kubectl get nodes -lnode-role.kubernetes.io/master!="",px/enabled!=false -o jsonpath='{.items[*].metadata.name}'); do
  (scp px-preflight.tar $i:/var/tmp && ssh $i docker load -i /var/tmp/px-preflight.tar) &
done
wait
