#!/usr/bin/env bash

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# This pod will apply the manifests inside the ConfigMap used by the ClusterResourceSet.
kubectl apply -f "${SCRIPT_DIR}/pod-test.yaml"

# We need to wait until the job is actually created, before we can 'kubectl wait' for it.
sleep 15

if [[ ! $(kubectl get psp privileged) ]]; then
  echo "Missing privileged PodSecurityPolicy"
  exit 1
fi
if [[ ! $(kubectl get psp restricted) ]]; then
  echo "Missing restricted PodSecurityPolicy"
  exit 1
fi

if [[ $(kubectl get pods -n kube-system | grep Error) ]]; then
  echo "There are pods erroring"
  exit 1
fi
