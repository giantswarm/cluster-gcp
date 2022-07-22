#!/usr/bin/env bash

#
# (PK) I couldn't find a better/simpler way to conifgure it. See:
# https://github.com/kubernetes-sigs/cluster-api/issues/4512
#

set -o errexit
set -o nounset
set -o pipefail

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly dir

# kubeadm config is in different directory in Flatcar (/etc) and Ubuntu (/run/kubeadm).
kubeadm_file="/etc/kubeadm.yml"
if [[ ! -f ${kubeadm_file} ]]; then
    kubeadm_file="/run/kubeadm/kubeadm.yaml"
fi

# Run this script only if this is the init node.
if [[ ! -f ${kubeadm_file} ]]; then
    exit 0
fi

# Exit fast if already appended.
if [[ ! -f ${dir}/gs-kube-proxy-config.yaml ]]; then
    exit 0
fi

cat "${dir}/gs-kube-proxy-config.yaml" >> "${kubeadm_file}"
rm "${dir}/gs-kube-proxy-config.yaml"
