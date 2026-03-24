#!/bin/bash

echo "Starting Chaos Monkey 2 (nodes)"

while true; do
  NODE=$(kubectl get nodes --no-headers | awk '{print $1}' | shuf -n 1)

  echo "Draining node: $NODE"
  kubectl drain "$NODE" --ignore-daemonsets --delete-emptydir-data --force

  echo "Sleeping 2 minutes..."
  sleep 120

  echo "Bringing node back: $NODE"
  kubectl uncordon "$NODE"

  sleep 30
done
