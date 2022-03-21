{{- define "machine-deployments" }}
{{ $global := . }}
{{ range .Values.machineDeployments }}
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachineDeployment
metadata:
  annotations:
    machine-deployment.giantswarm.io/name: {{ .name }}
  labels:
    giantswarm.io/machine-deployment: {{ .name }}
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ .name }}
  namespace: {{ $.Release.Namespace }}
spec:
  clusterName: {{ include "resource.default.name" $ }}
  replicas: {{ .replicas }}
  selector:
    matchLabels: null
  template:
    spec:
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
          kind: KubeadmConfigTemplate
          name: {{ .name }}
      clusterName: {{ include "resource.default.name" $ }}
      failureDomain: {{ .failureDomain }}
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: GCPMachineTemplate
        name: {{ .name }}
      version: {{ $.Values.kubernetesVersion }}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPMachineTemplate
metadata:
  labels:
    giantswarm.io/machine-pool: {{ .name }}
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ .name }}
  namespace: {{ $.Release.Namespace }}
spec:
  template:
    spec:
      image: {{ $global.Values.gcp.baseImage }}
      instanceType: {{ .instanceType }}
      rootDeviceSize: {{ .rootVolumeSizeGB }}
---
{{ end }}
{{- end -}}
