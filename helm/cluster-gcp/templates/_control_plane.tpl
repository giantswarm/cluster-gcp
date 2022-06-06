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
      name: {{ include "resource.default.name" $ }}-control-plane
  kubeadmConfigSpec:
    clusterConfiguration:
      apiServer:
        timeoutForControlPlane: 20m
        certSANs:
          - "api.{{ include "resource.default.name" $ }}.{{ .Values.baseDomain }}"
        extraArgs:
          cloud-provider: gce
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
          audit-log-maxage: "30"
          audit-log-maxbackup: "30"
          audit-log-maxsize: "100"
          audit-log-path: /var/log/apiserver/audit.log
          audit-policy-file: /etc/kubernetes/policies/audit-policy.yaml
          enable-admission-plugins: NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,DefaultStorageClass,PersistentVolumeClaimResize,Priority,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,PodSecurityPolicy
          feature-gates: TTLAfterFinished=true
          kubelet-preferred-address-types: InternalIP
          profiling: "false"
          runtime-config: api/all=true,scheduling.k8s.io/v1alpha1=true
          service-account-lookup: "true"
          tls-cipher-suites: TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256
          service-cluster-ip-range: {{ .Values.network.serviceCIDR }}
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
      controllerManager:
        extraArgs:
          allocate-node-cidrs: "false"
          bind-address: 0.0.0.0
          cloud-provider: gce
          cloud-config: /etc/kubernetes/gcp.conf
        extraVolumes:
        - hostPath: /etc/kubernetes/gcp.conf
          mountPath: /etc/kubernetes/gcp.conf
          name: cloud-config
          readOnly: true
      scheduler:
        extraArgs:
          bind-address: 0.0.0.0
      etcd:
        local:
          extraArgs:
            quota-backend-bytes: "8589934592"
      networking:
        serviceSubnet: {{ .Values.network.serviceCIDR }}
    files:
    {{- include "sshFiles" . | nindent 4 }}
    {{- include "diskFiles" . | nindent 4 }}
    {{- include "kubernetesFiles" . | nindent 4 }}
    initConfiguration:
      localAPIEndpoint:
        advertiseAddress: ""
        bindPort: {{ .Values.controlPlane.bindPort }}
      nodeRegistration:
        kubeletExtraArgs:
          cloud-provider: gce
          healthz-bind-address: 0.0.0.0
          image-pull-progress-deadline: 1m
          node-ip: '{{ `{{ ds.meta_data.local_ipv4 }}` }}'
          v: "2"
        name: '{{ `{{ ds.meta_data.local_hostname.split(".")[0] }}` }}'
    joinConfiguration:
      discovery: {}
      nodeRegistration:
        kubeletExtraArgs:
          cloud-provider: gce
        name: '{{ `{{ ds.meta_data.local_hostname.split(".")[0] }}` }}'
    postKubeadmCommands:
    {{- include "sshPostKubeadmCommands" . | nindent 4 }}
    users:
    {{- include "sshUsers" . | nindent 4 }}
  replicas: {{ .Values.controlPlane.replicas }}
  version: {{ .Values.kubernetesVersion }}
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPMachineTemplate
metadata:
  labels:
    cluster.x-k8s.io/role: control-plane
    {{- include "labels.common" $ | nindent 4 }}
  name: {{ include "resource.default.name" $ }}-control-plane
  namespace: {{ $.Release.Namespace }}
spec:
  template:
    spec:
      image: {{ .Values.gcp.baseImage }}
      instanceType: {{ .Values.controlPlane.instanceType }}
      rootDeviceSize: {{ .Values.controlPlane.rootVolumeSizeGB }}
      serviceAccounts:
        email: {{ .Values.controlPlane.serviceAccount.email }}
        scopes: {{ .Values.controlPlane.serviceAccount.scopes }}
{{- end -}}
