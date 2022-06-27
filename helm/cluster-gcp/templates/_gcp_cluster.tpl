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
    {{- if eq .Values.network.autoCreateSubnetworks false }}
    subnets:
    {{- range .Values.network.nodeSubnetCidrs }}
    - cidrBlock: {{ . }}
      region: {{ $.Values.gcp.region }}
    {{- end }}
    {{- end }}
  region: {{ .Values.gcp.region }}
  project: {{ .Values.gcp.project }}
  failureDomains:
    {{- range .Values.gcp.failureDomains }}
    {{- if (hasPrefix $.Values.gcp.region .) }}
    - {{ . }}
    {{- else -}}
    {{ fail (printf "Failure domain '%s' must be part of the provided region '%s'" . $.Values.gcp.region )}}
    {{- end -}}
    {{- end }}
{{ end }}
