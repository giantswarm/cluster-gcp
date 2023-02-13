{{/*
GCPMachineTemplates .Spec are immutable and cannot change.
This function is used for both the `.Spec` value and as the data for the hash function.
Any changes to this will trigger the resource to be recreated rather than attempting to update in-place.
*/}}
{{- define "machinedeployment-gcpmachinetemplate-spec" -}}
image: {{ .vmImage }}
instanceType: {{ .instanceType | default "n2-standard-4" }}
rootDeviceSize: {{ .rootVolumeSizeGB | default 100 }}
{{- if .serviceAccount }}
serviceAccounts:
  email: {{ .serviceAccount.email }}
  scopes: {{ .serviceAccount.scopes | toYaml | nindent 4 }}
{{- else }}
serviceAccounts:
  email: "default"
  scopes:
  - "https://www.googleapis.com/auth/compute"
{{- end }}
additionalDisks:
- deviceType: pd-ssd
  size: {{ .containerdVolumeSizeGB | default 100 }}
- deviceType: pd-ssd
  size: {{ .kubeletVolumeSizeGB | default 100 }}
subnet: {{ .resourceDefaultName }}-subnetwork
{{- end }}


{{/*
KubeadmConfigTemplate .Spec are immutable and cannot change.
This function is used for both the `.Spec` value and as the data for the hash function.
Any changes to this will trigger the resource to be recreated rather than attempting to update in-place.
*/}}
{{- define "machinedeployment-kubeadmconfigtemplate-spec" -}}
joinConfiguration:
  discovery: {}
  nodeRegistration:
    kubeletExtraArgs:
      cloud-provider: gce
      healthz-bind-address: 0.0.0.0
      image-pull-progress-deadline: 1m
      node-ip: '{{ `{{ ds.meta_data.local_ipv4 }}` }}'
      node-labels: role=worker,giantswarm.io/machine-deployment={{ .name }}{{ if .customNodeLabels }},{{- join "," .customNodeLabels }}{{ end }}
      v: "2"
    name: '{{ `{{ ds.meta_data.local_hostname.split(".")[0] }}` }}'
    {{- if .customNodeTaints }}
    {{- if (gt (len .customNodeTaints) 0) }}
    taints:
    {{- range .customNodeTaints }}
    - key: {{ .key | quote }}
      value: {{ .value | quote }}
      effect: {{ .effect | quote }}
    {{- end }}
    {{- end }}
    {{- end }}
files:
{{ .sshFiles }}
{{ .diskFiles }}
preKubeadmCommands:
{{- include "prepare-varLibKubelet-Dir" . | nindent 0 }}
- /bin/bash /opt/init-disks.sh
postKubeadmCommands:
{{ .sshPostKubeadmCommands }}
users:
{{ .sshUsers }}
{{- end }}


{{- define "machine-deployments" }}
{{ range .Values.machineDeployments }}

{{- $machineDeployment := . }}
{{- $_ := set $machineDeployment "vmImage" (include "vmImage" $) -}}
{{- $_ := set $machineDeployment "resourceDefaultName" (include "resource.default.name" $ | nindent 2) -}}
{{- $_ := set $machineDeployment "sshFiles" (include "sshFiles" $ | nindent 2) -}}
{{- $_ := set $machineDeployment "diskFiles" (include "diskFiles" $ | nindent 2) -}}
{{- $_ := set $machineDeployment "sshPostKubeadmCommands" (include "sshPostKubeadmCommands" $ | nindent 2) -}}
{{- $_ := set $machineDeployment "sshUsers" (include "sshUsers" $ | nindent 2) -}}

apiVersion: cluster.x-k8s.io/v1beta1
kind: MachineDeployment
metadata:
  annotations:
    machine-deployment.giantswarm.io/name: {{ .description | default ( printf "%s-%s" ( include "resource.default.name" $ ) ( .name ) ) | quote }}
  labels:
    giantswarm.io/machine-deployment: {{ include "resource.default.name" $ }}-{{ .name }}
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-{{ .name }}
  namespace: {{ $.Release.Namespace }}
spec:
  clusterName: {{ include "resource.default.name" $ }}
  revisionHistoryLimit: 0
  replicas: {{ .replicas }}
  selector:
    matchLabels: null
  template:
    metadata:
      labels:
        {{- include "labels.selector" $ | nindent 8 }}
    spec:
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
          kind: KubeadmConfigTemplate
          name: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" (dict "data" (include "machinedeployment-kubeadmconfigtemplate-spec" $machineDeployment) "global" $) }}
      clusterName: {{ include "resource.default.name" $ }}
      {{- if (hasPrefix $.Values.gcp.region .failureDomain) }}
      failureDomain: {{ .failureDomain }}
      {{- else -}}
      {{ fail (printf "Failure domain '%s' must be part of the provided region '%s'" .failureDomain $.Values.gcp.region )}}
      {{- end }}
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: GCPMachineTemplate
        name: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" (dict "data" (include "machinedeployment-gcpmachinetemplate-spec" $machineDeployment) "global" $) }}
      version: {{ $.Values.kubernetesVersion }}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPMachineTemplate
metadata:
  labels:
    giantswarm.io/machine-deployment: {{ include "resource.default.name" $ }}-{{ .name }}
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" (dict "data" (include "machinedeployment-gcpmachinetemplate-spec" $machineDeployment) "global" $) }}
  namespace: {{ $.Release.Namespace }}
spec:
  template:
    spec: {{ include "machinedeployment-gcpmachinetemplate-spec" $machineDeployment | nindent 6 }}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
  labels:
    giantswarm.io/machine-deployment: {{ include "resource.default.name" $ }}-{{ .name }}
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" (dict "data" (include "machinedeployment-kubeadmconfigtemplate-spec" $machineDeployment) "global" $) }}
  namespace: {{ $.Release.Namespace }}
spec:
  template:
    spec: {{ include "machinedeployment-kubeadmconfigtemplate-spec" $machineDeployment | nindent 6 }}
---
{{ end }}
{{- end -}}
