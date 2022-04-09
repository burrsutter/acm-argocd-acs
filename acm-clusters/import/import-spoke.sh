if [ -z "$1" ]
  then
    echo "cluster name required"
fi

kubectl apply -f $HOME/$1-klusterlet-crd.yaml

kubectl apply -f $HOME/$1-import.yaml

# watch kubectl get pods -n open-cluster-management-agent

watch kubectl get pods -n open-cluster-management-agent-addon