{{/*
GCPMachineTemplates .Spec are immutable and cannot change.
This function is used for both the `.Spec` value and as the data for the hash function.
Any changes to this will trigger the resource to be recreated rather than attempting to update in-place.
*/}}
{{- define "bastion-gcpmachinetemplate-spec" -}}
instanceType: {{ .Values.bastion.instanceType }}
publicIP: true
additionalNetworkTags:
- {{ include "resource.default.name" $ }}-bastion
image: {{ include "vmImage" $ }}
subnet: {{ include "resource.default.name" $ }}-subnetwork
{{- end }}

{{/*
KubeadmConfigTemplate .Spec are immutable and cannot change.
This function is used for both the `.Spec` value and as the data for the hash function.
Any changes to this will trigger the resource to be recreated rather than attempting to update in-place.
*/}}
{{- define "bastion-kubeadmconfigtemplate-spec" -}}
preKubeadmCommands:
{{- include "sshPostKubeadmCommands" $ | nindent 2 }}
  - sleep infinity
files:
{{- include "sshFilesBastion" $ | nindent 2 }}
users:
{{- include "sshUsers" . | nindent 2 }}
{{- end }}

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
  revisionHistoryLimit: 0
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
        cluster.x-k8s.io/deployment-name: {{ include "resource.default.name" $ }}-bastion
        {{- include "labels.selector" $ | nindent 8 }}
    spec:
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
          kind: KubeadmConfigTemplate
          name: {{ include "resource.default.name" $ }}-bastion-{{ include "hash" (dict "data" (include "bastion-kubeadmconfigtemplate-spec" $) "global" .) }}
      clusterName: {{ include "resource.default.name" $ }}
      failureDomain: {{ index .Values.gcp.failureDomains 0 }}
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: GCPMachineTemplate
        name: {{ include "resource.default.name" $ }}-bastion-{{ include "hash" (dict "data" (include "bastion-gcpmachinetemplate-spec" $) "global" .) }}
      version: {{ .Values.kubernetesVersion }}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPMachineTemplate
metadata:
  labels:
    cluster.x-k8s.io/role: bastion
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-bastion-{{ include "hash" (dict "data" (include "bastion-gcpmachinetemplate-spec" $) "global" .) }}
  namespace: {{ .Release.Namespace }}
spec:
  template:
    spec: {{ include "bastion-gcpmachinetemplate-spec" $ | nindent 6 }}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
  labels:
    cluster.x-k8s.io/role: bastion
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-bastion-{{ include "hash" (dict "data" (include "bastion-kubeadmconfigtemplate-spec" $) "global" .) }}
  namespace: {{ $.Release.Namespace }}
spec:
  template:
    spec: {{ include "bastion-kubeadmconfigtemplate-spec" $ | nindent 6 }}
{{- end -}}
