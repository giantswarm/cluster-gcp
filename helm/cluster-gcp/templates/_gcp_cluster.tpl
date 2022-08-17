{{- define "gcp-cluster" }}
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPCluster
metadata:
  annotations:
    bastion.gcp.giantswarm.io/allowlist: {{ .Values.bastion.allowlistSubnets }}
  labels:
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}
  namespace: {{ .Release.Namespace }}
spec:
  network:
    name: {{ include "resource.default.name" $ }}-network
    autoCreateSubnetworks: false
    subnets:
    - cidrBlock: {{ .Values.network.nodeSubnetCidr }}
      region: {{ $.Values.gcp.region }}
      routeTableId: false
      enableFlowLogs: false
  region: {{ .Values.gcp.region }}
  project: {{ required "You must provide the GCP Project ID" .Values.gcp.project }}
  failureDomains:
    {{- range .Values.gcp.failureDomains }}
    {{- if (hasPrefix $.Values.gcp.region .) }}
    - {{ . }}
    {{- else -}}
    {{ fail (printf "Failure domain '%s' must be part of the provided region '%s'" . $.Values.gcp.region )}}
    {{- end -}}
    {{- end }}
{{ end }}
