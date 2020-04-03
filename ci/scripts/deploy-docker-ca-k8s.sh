#!/bin/bash
set -eux
BASE64_CERT=$(echo "${CA_CERT}" | base64 -w 0)

# KUBECTL_VERSION=$(cat kubectl-release/version)
KUBECTL_VERSION=$(curl https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo $KUBECTL_VERSION
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod +x ./kubectl
cp kubectl /usr/bin

export KUBECONFIG=$(pwd)/kubeconfig/kubeconfig-$(cat kubeconfig/version).json

kubectl cluster-info
kubectl get nodes
kubectl get componentstatuses

echo "Creating registry Secret"
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
  name: registry-ca
  namespace: kube-system
type: Opaque
data:
  registry-ca: ${BASE64_CERT}
EOF

"Creating Registry Daemon Set"
cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: registry-ca
  namespace: kube-system
  labels:
    k8s-app: registry-ca
spec:
  template:
    metadata:
      labels:
        name: registry-ca
    spec:
      containers:
      - name: registry-ca
        image: busybox
        command: [ 'sh' ]
        args: [ '-c', 'cp /home/core/registry-ca /etc/docker/certs.d/${REGISTRY_HOSTNAME}/ca.crt && exec tail -f /dev/null' ]
        volumeMounts:
        - name: etc-docker
          mountPath: /etc/docker/certs.d/${REGISTRY_HOSTNAME}
        - name: ca-cert
          mountPath: /home/core
      terminationGracePeriodSeconds: 30
      volumes:
      - name: etc-docker
        hostPath:
          path: /etc/docker/certs.d/${REGISTRY_HOSTNAME}
      - name: ca-cert
        secret:
          secretName: registry-ca
EOF

echo "Done"
