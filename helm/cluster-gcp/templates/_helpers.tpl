{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "labels.common" -}}
{{- include "labels.selector" $ }}
helm.sh/chart: {{ include "chart" . | quote }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "labels.selector" -}}
app: {{ include "name" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
cluster.x-k8s.io/cluster-name: {{ include "resource.default.name" . | quote }}
giantswarm.io/cluster: {{ include "resource.default.name" . | quote }}
giantswarm.io/organization: {{ required "You must provide an existing organization" .Values.organization | quote }}
{{- end -}}

{{/*
Create a name stem for resource names
When resources are created from templates by Cluster API controllers, they are given random suffixes.
Given that Kubernetes allows 63 characters for resource names, the stem is truncated to 47 characters to leave
room for such suffix.
*/}}
{{- define "resource.default.name" -}}
{{ .Values.clusterName }}
{{- end -}}

{{- define "sshFiles" -}}
- path: /etc/ssh/trusted-user-ca-keys.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssh/trusted-user-ca-keys.pem") . | b64enc }}
- path: /etc/ssh/sshd_config
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/ssh/sshd_config" | b64enc }}
{{- end -}}

{{- define "sshFilesBastion" -}}
- path: /etc/ssh/trusted-user-ca-keys.pem
  permissions: "0600"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/ssh/trusted-user-ca-keys.pem") . | b64enc }}
- path: /etc/ssh/sshd_config
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/ssh/sshd_config_bastion" | b64enc }}
{{- end -}}

{{- define "diskFiles" -}}
- path: /opt/init-disks.sh
  permissions: "0700"
  encoding: base64
  content: {{ $.Files.Get "files/opt/init-disks.sh" | b64enc }}
{{- end -}}

{{- define "kubernetesFiles" -}}
- path: /etc/kubernetes/policies/audit-policy.yaml
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/kubernetes/policies/audit-policy.yaml" | b64enc }}
- path: /etc/kubernetes/gcp.conf
  permissions: "0600"
  encoding: base64
  content: {{ include "kubernetesCloudConfigurationFile" $ | b64enc }}
- path: /etc/kubernetes/encryption/config.yaml
  permissions: "0600"
  contentFrom:
    secret:
      name: {{ include "resource.default.name" $ }}-encryption-provider-config
      key: encryption
{{- end -}}

{{- define "kubernetesCloudConfigurationFile" -}}
[global]
multizone = true
network-name={{ include "resource.default.name" $ }}-network
subnetwork-name={{ include "resource.default.name" $ }}-subnetwork
{{- end -}}

{{- define "sshPostKubeadmCommands" -}}
- systemctl restart sshd
{{- end -}}

{{- define "diskPreKubeadmCommands" -}}
- /bin/sh /opt/init-disks.sh
{{- end -}}

{{- define "sshUsers" -}}
- name: giantswarm
  groups: sudo
  sudo: ALL=(ALL) NOPASSWD:ALL
{{- end -}}

{{- define "vmImage" -}}
{{ .Values.vmImageBase }}cluster-api-ubuntu-{{ .Values.ubuntuImageVersion }}-v{{ .Values.kubernetesVersion | replace "." "-" }}-gs
{{- end -}}

{{- define "prepare-varLibKubelet-Dir" -}}
- /bin/test ! -d /var/lib/kubelet && (/bin/mkdir -p /var/lib/kubelet && /bin/chmod 0750 /var/lib/kubelet)
{{- end -}}

{{/*
Hash function based on data provided
Expects two arguments (as a `dict`) E.g.
  {{ include "hash" (dict "data" . "global" $global) }}
Where `data` is the data to hash on and `global` is the top level scope.
*/}}
{{- define "hash" -}}
{{- $data := mustToJson .data | toString  }}
{{- $salt := "" }}
{{- if .global.Values.hashSalt }}{{ $salt = .global.Values.hashSalt}}{{end}}
{{- (printf "%s%s" $data $salt) | quote | sha1sum | trunc 8 }}
{{- end -}}

{{- define "kubeProxyFiles" }}
- path: /etc/gs-kube-proxy-config.yaml
  permissions: "0600"
  content: |
    {{- .Files.Get "files/etc/gs-kube-proxy-config.yaml" | nindent 4 }}
- path: /etc/gs-kube-proxy-patch.sh
  permissions: "0700"
  content: |
    {{- .Files.Get "files/etc/gs-kube-proxy-patch.sh" | nindent 4 }}
{{- end -}}
