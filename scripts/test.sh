#!/usr/bin/env bash

#readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#
## This pod will apply the ClusterResourceSet manifests so that we have them in a configmap.
#kubectl apply -f "${SCRIPT_DIR}/pod-test.yaml"
#
## We need to wait until the job is actually created, before we can 'kubectl wait' for it.
#sleep 10

# Check that everything is as expected.
kubectl -n kube-system wait --timeout 100s --for condition=complete job/coredns-adopter
kubectl -n kube-system wait --timeout 1s --for condition=available deploy/coredns-workers

if [[ ! $(kubectl get svc -n kube-system coredns) ]]; then
  echo "Missing coredns Service"
  exit 1
fi

if [[ ! $(kubectl get job -n kube-system coredns-adopter -o json | jq '.status.succeeded') ]]; then
  echo "coredns-adopter job is not marked as succeeded"
  exit 1
fi

if [[ $(kubectl get pods -n kube-system | grep Error) ]]; then
  echo "There are pods erroring"
  exit 1
fi
