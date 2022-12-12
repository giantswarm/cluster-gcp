{{- define "cluster" }}
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  annotations:
    cluster.giantswarm.io/description: "{{ .Values.clusterDescription }}"
  labels:
    cluster-apps-operator.giantswarm.io/watching: ""
    {{- if ne .Values.servicePriority "" }}
    giantswarm.io/service-priority: {{ .Values.servicePriority }}
    {{- end }}
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}
  namespace: {{ .Release.Namespace }}
spec:
  clusterNetwork:
    pods:
      cidrBlocks: {{ .Values.network.podCidr }}
  controlPlaneRef:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta1
    kind: KubeadmControlPlane
    name: {{ include "resource.default.name" $ }}
  infrastructureRef:
    apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
    kind: GCPCluster
    name: {{ include "resource.default.name" $ }}
{{- end -}}
