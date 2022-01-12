docker save px-preflight -o px-preflight.tar

for i in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  scp px-preflight.tar $i:/var/tmp
  ssh $i docker load -i /var/tmp/px-preflight.tar
done
