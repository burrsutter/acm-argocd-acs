if [ -z "$1" ]
  then
    echo "cluster name required"
fi

echo $1

kubectl create namespace $1
kubectl label namespace $1 cluster.open-cluster-management.io/managedCluster=$1

cat <<EOF > "managedcluster-$1.yaml"
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: $1
  labels:
    observability: disabled
spec:
  hubAcceptsClient: true
EOF

kubectl -n $1 apply -f managedcluster-$1.yaml

cat <<EOF > "kac-$1.yaml"
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: $1
  namespace: $1
spec:
  clusterName: $1
  clusterNamespace: $1
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  clusterLabels:
    cloud: auto-detect
    vendor: auto-detect
  iamPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  version: 2.1.0
EOF

kubectl -n $1 apply -f kac-$1.yaml

kubectl get secret $1-import -n $1 -o jsonpath={.data.crds\\.yaml} | base64 --decode > $HOME/$1-klusterlet-crd.yaml

echo "CRD generated:" $HOME/$1-klusterlet-crd.yaml

kubectl get secret $1-import -n $1 -o jsonpath={.data.import\\.yaml} | base64 --decode > $HOME/$1-import.yaml

echo "Import generated:" $HOME/$1-import.yaml