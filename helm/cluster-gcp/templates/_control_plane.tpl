{{/*
GCPMachineTemplates .Spec are immutable and cannot change.
This function is used for both the `.Spec` value and as the data for the hash function.
Any changes to this will trigger the resource to be recreated rather than attempting to update in-place.
*/}}
{{- define "controlplane-gcpmachinetemplate-spec" -}}
image: {{ include "vmImage" $ }}
instanceType: {{ .Values.controlPlane.instanceType }}
rootDeviceSize: {{ .Values.controlPlane.rootVolumeSizeGB }}
additionalDisks:
- deviceType: pd-ssd
  size: {{ .Values.controlPlane.etcdVolumeSizeGB }}
- deviceType: pd-ssd
  size: {{ .Values.controlPlane.containerdVolumeSizeGB }}
- deviceType: pd-ssd
  size: {{ .Values.controlPlane.kubeletVolumeSizeGB }}
subnet: {{ include "resource.default.name" $ }}-subnetwork
serviceAccounts:
  email: {{ .Values.controlPlane.serviceAccount.email }}
  scopes: {{ .Values.controlPlane.serviceAccount.scopes | toYaml | nindent 4 }}
{{- end }}


{{- define "control-plane" }}
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
metadata:
  labels:
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}
  namespace: {{ $.Release.Namespace }}
spec:
  machineTemplate:
    metadata:
      labels:
        {{- include "labels.common" $ | nindent 8 }}
    infrastructureRef:
      apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
      kind: GCPMachineTemplate
      name: {{ include "resource.default.name" $ }}-control-plane-{{ include "hash" (dict "data" (include "controlplane-gcpmachinetemplate-spec" $) "global" .) }}
  kubeadmConfigSpec:
    clusterConfiguration:
      # Avoid accessibility issues (e.g. on private clusters) and potential future rate limits for the default `registry.k8s.io`
      imageRepository: docker.io/giantswarm
      apiServer:
        timeoutForControlPlane: 20m
        certSANs:
          - "api.{{ include "resource.default.name" $ }}.{{ required "The baseDomain value is required" .Values.baseDomain }}"
          - 127.0.0.1
          - localhost
        extraArgs:
          audit-log-maxage: "30"
          audit-log-maxbackup: "30"
          audit-log-maxsize: "100"
          audit-log-path: /var/log/apiserver/audit.log
          audit-policy-file: /etc/kubernetes/policies/audit-policy.yaml
          cloud-provider: gce
          enable-admission-plugins: NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,PersistentVolumeClaimResize,DefaultStorageClass,Priority,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,PodSecurityPolicy
          encryption-provider-config: /etc/kubernetes/encryption/config.yaml
          feature-gates: TTLAfterFinished=true
          kubelet-preferred-address-types: InternalIP
          logtostderr: "true"
          {{- if .Values.oidc.issuerUrl }}
          {{- with .Values.oidc }}
          oidc-issuer-url: {{ .issuerUrl }}
          oidc-client-id: {{ .clientId }}
          oidc-username-claim: {{ .usernameClaim }}
          oidc-groups-claim: {{ .groupsClaim }}
          {{- if .caFile }}
          oidc-ca-file: {{ .caFile }}
          {{- end }}
          {{- end }}
          {{- end }}
          profiling: "false"
          runtime-config: api/all=true
          service-account-lookup: "true"
          service-cluster-ip-range: {{ .Values.network.serviceCIDR }}
          tls-cipher-suites: TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256
        extraVolumes:
        - name: auditlog
          hostPath: /var/log/apiserver
          mountPath: /var/log/apiserver
          readOnly: false
          pathType: DirectoryOrCreate
        - name: policies
          hostPath: /etc/kubernetes/policies
          mountPath: /etc/kubernetes/policies
          readOnly: false
          pathType: DirectoryOrCreate
        - name: encryption
          hostPath: /etc/kubernetes/encryption
          mountPath: /etc/kubernetes/encryption
          readOnly: false
          pathType: DirectoryOrCreate
      controllerManager:
        extraArgs:
          allocate-node-cidrs: "true"
          authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
          bind-address: 0.0.0.0
          cloud-provider: gce
          cloud-config: /etc/kubernetes/gcp.conf
          cluster-cidr: {{ join "," .Values.network.podCidr }}
          logtostderr: "true"
          profiling: "false"
        extraVolumes:
        - hostPath: /etc/kubernetes/gcp.conf
          mountPath: /etc/kubernetes/gcp.conf
          name: cloud-config
          readOnly: true
      scheduler:
        extraArgs:
          authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"
          bind-address: 0.0.0.0
      etcd:
        local:
          imageTag: {{.Values.controlPlane.etcd.imageTag}}
          extraArgs:
            listen-metrics-urls: "http://0.0.0.0:2381"
            quota-backend-bytes: "8589934592"
      networking:
        serviceSubnet: {{ .Values.network.serviceCIDR }}
    files:
    {{- include "sshFiles" . | nindent 4 }}
    {{- include "diskFiles" . | nindent 4 }}
    {{- include "kubeProxyFiles" . | nindent 4 }}
    {{- include "kubernetesFiles" . | nindent 4 }}
    initConfiguration:
      skipPhases:
      - addon/kube-proxy
      - addon/coredns
      localAPIEndpoint:
        advertiseAddress: ""
        bindPort: 0
      nodeRegistration:
        kubeletExtraArgs:
          cloud-provider: gce
          healthz-bind-address: 0.0.0.0
          image-pull-progress-deadline: 1m
          node-ip: '{{ `{{ ds.meta_data.local_ipv4 }}` }}'
          v: "2"
        name: '{{ `{{ ds.meta_data.local_hostname.split(".")[0] }}` }}'
        {{- if .Values.controlPlane.customNodeTaints }}
        {{- if (gt (len .Values.controlPlane.customNodeTaints) 0) }}
        taints:
        {{- range .Values.controlPlane.customNodeTaints }}
        - key: {{ .key | quote }}
          value: {{ .value | quote }}
          effect: {{ .effect | quote }}
        {{- end }}
        {{- end }}
        {{- end }}
    joinConfiguration:
      discovery: {}
      nodeRegistration:
        kubeletExtraArgs:
          cloud-provider: gce
        name: '{{ `{{ ds.meta_data.local_hostname.split(".")[0] }}` }}'
        {{- if .Values.controlPlane.customNodeTaints }}
        {{- if (gt (len .Values.controlPlane.customNodeTaints) 0) }}
        taints:
        {{- range .Values.controlPlane.customNodeTaints }}
        - key: {{ .key | quote }}
          value: {{ .value | quote }}
          effect: {{ .effect | quote }}
        {{- end }}
        {{- end }}
        {{- end }}
    preKubeadmCommands:
    {{- include "prepare-varLibKubelet-Dir" . | nindent 4 }}
    - /bin/bash /opt/init-disks.sh
    - /bin/bash /etc/gs-kube-proxy-patch.sh
    postKubeadmCommands:
    {{- include "sshPostKubeadmCommands" . | nindent 4 }}
    users:
    {{- include "sshUsers" . | nindent 4 }}
  replicas: 3
  version: v{{ trimPrefix "v" .Values.kubernetesVersion }}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPMachineTemplate
metadata:
  labels:
    cluster.x-k8s.io/role: control-plane
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-control-plane-{{ include "hash" (dict "data" (include "controlplane-gcpmachinetemplate-spec" $) "global" .) }}
  namespace: {{ $.Release.Namespace }}
spec:
  template:
    spec: {{ include "controlplane-gcpmachinetemplate-spec" $ | nindent 6 }}
{{- end -}}
