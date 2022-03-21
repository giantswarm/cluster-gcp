{{- define "gcp-cluster" }}
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPCluster
metadata:
  labels:
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}
  namespace: {{ .Release.Namespace }}
spec:
  network:
    name: {{ include "resource.default.name" $ }}-network
    autoCreateSubnetworks: {{ .Values.network.autoCreateSubnetworks }}
  region: {{ .Values.gcp.region }}
  project: {{ .Values.gcp.project }}
  failureDomains: {{ .Values.gcp.failureDomains }}
  additionalLabels: {{ .Values.gcp.additionalLabels }}
{{ end }}
