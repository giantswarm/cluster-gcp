#!/bin/sh
CONTAINERD_DISK="/dev/sdb"
KUBELET_DISK="/dev/sdc"
ETCD_DISK="/dev/sdd"

# init kubelet disk
mkfs.xfs $KUBELET_DISK
mkdir -p /var/lib/kubelet
mount $KUBELET_DISK /var/lib/kubelet

# init containerd disk
mkfs.xfs $CONTAINERD_DISK
systemctl stop containerd
rm -rf /var/lib/containerd
mkdir -p /var/lib/containerd
mount $CONTAINERD_DISK /var/lib/containerd
systemctl start containerd

if [ -e "${ETCD_DISK}" ]; then
        # init etcd disk
        mkfs.xfs $ETCD_DISK
        mkdir -p /var/lib/etcd
        mount $ETCD_DISK /var/lib/etcd
fi
