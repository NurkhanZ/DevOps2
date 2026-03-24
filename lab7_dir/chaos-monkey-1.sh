#!/bin/bash

NAMESPACE=${1:-default}

echo "Starting Chaos Monkey 1 (pods)"

while true; do
  POD=$(kubectl get pods -n $NAMESPACE \
    --field-selector=status.phase=Running \
    --no-headers | \
    grep -vE 'coredns|etcd|kube-apiserver|kube-controller|kube-proxy' | \
    awk '{print $1}' | shuf -n 1)

  if [ -n "$POD" ]; then
    echo "Deleting pod: $POD"
    kubectl delete pod "$POD" -n $NAMESPACE
  fi

  sleep 1
done
