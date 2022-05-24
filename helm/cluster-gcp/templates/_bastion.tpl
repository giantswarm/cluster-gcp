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
    metadata:
      labels:
        cluster.x-k8s.io/role: bastion
        {{- include "labels.common" $ | nindent 8 }}
    spec:
      instanceType: {{ .Values.bastion.instanceType }}
      publicIP: true
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
      preKubeadmCommands:
      {{- include "sshPostKubeadmCommands" $ | nindent 6 }}
      - sleep infinity
      files:
      {{- include "sshFilesBastion" $ | nindent 6 }}
      users:
      {{- include "sshUsers" . | nindent 6 }}
{{- end -}}
