{{- define "bastion" }}
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachineDeployment
metadata:
  labels:
    cluster.x-k8s.io/role: bastion
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-bastion
  namespace: {{ .Release.Namespace }}
spec:
  clusterName: {{ include "resource.default.name" $ }}
  replicas: {{ .Values.bastion.replicas }}
  selector:
    matchLabels: null
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        cluster.x-k8s.io/cluster-name: {{ include "resource.default.name" $ }}
        cluster.x-k8s.io/deployment-name: {{ include "resource.default.name" $ }}-bastion
        {{- include "labels.common" $ | nindent 8 }}
    spec:
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
          kind: KubeadmConfigTemplate
          name: {{ include "resource.default.name" $ }}-bastion
      clusterName: {{ include "resource.default.name" $ }}
      failureDomain: {{ index .Values.gcp.failureDomains 0 }}
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: GCPMachineTemplate
        name: {{ include "resource.default.name" $ }}-bastion
      version: {{ .Values.kubernetesVersion }}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPMachineTemplate
metadata:
  labels:
    cluster.x-k8s.io/role: bastion
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-bastion
  namespace: {{ .Release.Namespace }}
spec:
  template:
    spec:
      instanceType: {{ .Values.bastion.instanceType }}
      publicIP: true
      additionalNetworkTags:
      - {{ include "resource.default.name" $ }}-bastion
      image: {{ .Values.bastion.image }}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
  labels:
    cluster.x-k8s.io/role: bastion
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-bastion
  namespace: {{ $.Release.Namespace }}
spec:
  template:
    spec:
      joinConfiguration:
        discovery: {}
        nodeRegistration:
          kubeletExtraArgs:
            cloud-provider: gce
            healthz-bind-address: 0.0.0.0
            image-pull-progress-deadline: 1m
            node-ip: '{{ `{{ ds.meta_data.local_ipv4 }}` }}'
            node-labels: role=worker,giantswarm.io/machine-deployment={{ .name }},{{- join "," .customNodeLabels }}
            v: "2"
          name: '{{ `{{ ds.meta_data.local_hostname.split(".")[0] }}` }}'
      preKubeadmCommands:
      {{- include "sshPostKubeadmCommands" $ | nindent 6 }}
      - sleep infinity
      files:
      {{- include "sshFilesBastion" $ | nindent 6 }}
      users:
      {{- include "sshUsers" . | nindent 6 }}
{{- end -}}
