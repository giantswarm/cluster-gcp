{{- define "machine-deployments" }}
{{ $global := . }}
{{ range .Values.machineDeployments }}
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
          name: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" . }}
      clusterName: {{ include "resource.default.name" $ }}
      {{- if (hasPrefix $.Values.gcp.region .failureDomain) }}
      failureDomain: {{ .failureDomain }}
      {{- else -}}
      {{ fail (printf "Failure domain '%s' must be part of the provided region '%s'" .failureDomain $.Values.gcp.region )}}
      {{- end }}
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: GCPMachineTemplate
        name: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" . }}
      version: {{ $.Values.kubernetesVersion }}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPMachineTemplate
metadata:
  labels:
    giantswarm.io/machine-deployment: {{ include "resource.default.name" $ }}-{{ .name }}
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" . }}
  namespace: {{ $.Release.Namespace }}
spec:
  template:
    spec:
      image: {{ include "vmImage" $global }}
      instanceType: {{ .instanceType | default "n2-standard-4" }}
      rootDeviceSize: {{ .rootVolumeSizeGB | default 100 }}
      serviceAccounts:
        email: {{ .serviceAccount.email }}
        scopes: {{ .serviceAccount.scopes }}
      additionalDisks:
      - deviceType: pd-ssd
        size: {{ .containerdVolumeSizeGB | default 100 }}
      - deviceType: pd-ssd
        size: {{ .kubeletVolumeSizeGB | default 100 }}
      {{- if .subnet }}
      subnet: {{ .subnet }}
      {{- end }}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
metadata:
  labels:
    giantswarm.io/machine-deployment: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" . }}
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-{{ .name }}-{{ include "hash" . }}
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
            node-labels: role=worker,giantswarm.io/machine-deployment={{ .name }}{{ if .customNodeLabels }},{{- join "," .customNodeLabels }}{{ end }}
            v: "2"
          name: '{{ `{{ ds.meta_data.local_hostname.split(".")[0] }}` }}'
      files:
      {{- include "sshFiles" $ | nindent 6 }}
      {{- include "diskFiles" $ | nindent 6 }}
      preKubeadmCommands:
      - /bin/bash /opt/init-disks.sh
      postKubeadmCommands:
      {{- include "sshPostKubeadmCommands" . | nindent 6 }}
      users:
      {{- include "sshUsers" . | nindent 6 }}
---
{{ end }}
{{- end -}}
