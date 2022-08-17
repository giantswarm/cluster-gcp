# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.24.0] - 2022-08-11

### Fixed

- Corectly render several scopes for the service accounts.

## [0.23.0] - 2022-08-11

### Changed

- Make `organization` a mandatory value to pass when installing the chart.
- The `description` value is empty by default now.

### Added

- Optional `hashSalt` value to force recreation of immutable resources

## [0.22.0] - 2022-08-11

### Added

- Allow to choose the Google Service Account to set for worker nodes.

## [0.21.0] - 2022-08-11

### Fixed

- Revert #122 - do not set the certificates directory and CA certificates path in KubeadmControlPanel and KubeadmConfigTemplate

### Added

- Add `localhost` and `127.0.0.1` to the certSANs of apiserver certificates.

## [0.20.1] - 2022-08-10

### Fixed

- Ensure default values are used for `GCPMachineTemplate` if incomplete `machineDeployments` are provided

### Changed

- Set certificates directory to `/etc/kubernetes/ssl` in KubeadmControlPanel and KubeadmConfigTemplate `clusterConfiguration`.
- Set CA certificate path to `/etc/kubernetes/ssl/ca.crt` in KubeadmControlPanel and KubeadmConfigTemplate `joinConfiguration`.
- Always create a single subnet on the VPC, where only the subnet CIDR is configurable.

## [0.20.0] - 2022-07-28

### Removed

- `replicas` value from `controlPlane` no longer configurable - always set to 3 for HA

## [0.19.1] - 2022-07-22

### Fixed

- Fix kube-proxy config file provisioning.

## [0.19.0] - 2022-07-21

### Changed

- Set `authorization-always-allow-paths: "/healthz,/readyz,/livez,/metrics"` to `scheduler` and `controller-manager`
- Order `kubeadm` extraFlags alphabetically.
- Set `logtostderr: "true"` to `controller-manager`.
- Make `etcd` metrics endpoint accessible.
- Expose `kube-proxy` metrics.
- Remove `scheduling.k8s.io/v1alpha1=true` from `runtime-config` because it's already included on `api/all=true`.

## [0.18.0] - 2022-07-20

### Fixed

- Set `routeTableId: false` when passing `nodeSubnetCidrs` as it's mandatory.

## [0.17.0] - 2022-07-20

### Added

- Add subnet allowlist for bastion SSH port 22.

## [0.16.0] - 2022-07-15

### Changed

- Make etcd image registry customizable

### Fixed

- Use correct etcd image details


## [0.15.1] - 2022-07-07

### Changed

- Bumped default etcd version to avoid the 3.5.0 issues (See https://github.com/etcd-io/etcd/releases/tag/v3.5.0)
- Made etcd version configurable via values

### Fixed

- Moved custom make targets to correct Makefile

## [0.15.0] - 2022-07-06

### Changed

- Updated Kubernetes version to `v1.22.10`
- Switched Ubuntu version to `2004`
- Made GCP Project ID required (and defaulted to "")

### Added

- Added tests to check coredns-adopter logic.

## [0.14.3] - 2022-07-01

### Added

- Add labels to `MachineSets` created by `MachineDeployments`.
- Add additional disks for control plane nodes.
- Add additional disks for worker nodes.
- Add support for secret encryption at rest.
- Allow to set nodepool description through Helm values.

## [0.14.2] - 2022-06-29

### Fixed

- Bump cluster-shared

## [0.14.1] - 2022-06-29

### Fixed

- Added missing hash to template names

### Changed

- Bumped cluster-shared to latest 0.5.6

## [0.14.0] - 2022-06-28

### Changed

- Immutable resources now use a unique name to allow for updates to be made

## [0.13.5] - 2022-06-28

### Changed

- Bumped cluster-shared to latest 0.5.5

## [0.13.4] - 2022-06-28

### Changed

- Bumped cluster-shared to latest 0.5.4

## [0.13.3] - 2022-06-28

### Changed

- Bumped cluster-shared to latest 0.5.3

## [0.13.2] - 2022-06-28

### Changed

- Bumped cluster-shared to latest 0.5.2

## [0.13.1] - 2022-06-27

### Added

- Support specifying custom subnets

### Fixed

- Makefile task to generate values schema

## [0.13.0] - 2022-06-23

### Added

- Add value to configure the vm image's ubuntu version

## [0.12.8] - 2022-06-20

- Bumped cluster-shared to latest

## [0.12.7] - 2022-06-20

### Added

- Make task for updating chart deps

### Changed

- Bumped cluster-shared to latest

## [0.12.6] - 2022-06-17

## [0.12.5] - 2022-06-17

## [0.12.4] - 2022-06-17

### Fixed

- Remove chart label from selector labels

## [0.12.3] - 2022-06-17

### Fixed

- Bumped version of cluster-shared to include coredns-workers fix

## [0.12.2] - 2022-06-16

### Fixed

- Set bastion machine image.

## [0.12.1] - 2022-06-16

### Changed

- Bumped to latest cluster-shared (0.4.0)

## [0.12.0] - 2022-06-14

### Changed

- Updated VM image location
- Bumped kubernetes version to 1.20.15

### Added

- Make task to generate values schema

## [0.11.0] - 2022-06-13

- Make bastion node optional via config values.

## [0.10.2] - 2022-06-10

- Remove metadata from bastion GCPMAchineTemplates's template. This isn't currenlty supported in capg v1.0.2

## [0.10.1] - 2022-06-07

### Fixed

- Prevent setting a failureDomain not in the specified region

## [0.10.0] - 2022-06-06

- Add bastion support.

## [0.9.0] - 2022-05-31

### Fixed

- Render failure domains on the `GCPCluster` as an array.
- Use same service account default than CAPG.

## [0.8.0] - 2022-05-30

### Added

- Allow to pass OIDC configuration.

## [0.7.0] - 2022-05-27

### Changed

- Set `certSANs` on the k8s api server so that certificates work.

## [0.6.2] - 2022-05-26

- Add `cloud-config` for GCP cloud provider to enable multizone for controller manager.

## [0.6.1] - 2022-05-13

- Set the `scopes` (`compute-rw` by default) on control-plane's MachineTemplate Service Account

## [0.6.0] - 2022-05-12

### Changed

- Add team label to helm resources.
- Add `values.schema.json` file.
- Add Service Account to control-plane MachineTemplate

## [0.5.1] - 2022-04-28

- Fix helm not generating all KubeadmConfigTemplate's for each machine deployment

## [0.5.0] - 2022-04-28

- Move default instance type from n1-standard-2 with 2 vCPU and 7Gbi to n2-standard-4 with 4 vCPU and 16Gbi
- Bump default control-plane nodes to 3
- Use 3 machineDeployments in different availability zones
- Move to the `europe-west3` region by default

## [0.4.2] - 2022-04-13

### Changed

- Updated to use latest `cluster-shared` as a library chart

## [0.4.1] - 2022-04-13

### Changed

- Updated to latest `cluster-shared` sub chart

## [0.4.0] - 2022-04-12

### Changed

- Switched to using cluster-shared sub-chart for ClusterResourceSets

## [0.3.1] - 2022-04-11

### Changed

- Recreate coredns deployment ready for app to overwrite rather than deleting completely

## [0.3.0] - 2022-04-08

### Changed

- Use `.Chart.Version` instead of `.Chart.AppVersion` to get correct `app.kubernetes.io/version` label on resources.
- Use same kubernetes version that is used in the OS images.
- Use new `.clusterName` value as the base name of resources instead of `.Release.Name` to keep names cleaner.

## [0.2.0] - 2022-04-07

### Added

- Enabled PSPs and added default policies

### Changed

- Adopt default coredns so we can override with our app

## [0.1.1] - 2022-03-25

- Remove unused labels for `release` and `watch-filter`.

## [0.1.0]

[Unreleased]: https://github.com/giantswarm/cluster-gcp/compare/v0.24.0...HEAD
[0.24.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.23.0...v0.24.0
[0.23.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.22.0...v0.23.0
[0.22.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.21.0...v0.22.0
[0.21.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.20.1...v0.21.0
[0.20.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.20.0...v0.20.1
[0.20.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.19.1...v0.20.0
[0.19.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.19.0...v0.19.1
[0.19.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.17.0...v0.18.0
[0.17.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.16.0...v0.17.0
[0.16.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.15.1...v0.16.0
[0.15.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.15.0...v0.15.1
[0.15.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.14.3...v0.15.0
[0.14.3]: https://github.com/giantswarm/cluster-gcp/compare/v0.14.2...v0.14.3
[0.14.2]: https://github.com/giantswarm/cluster-gcp/compare/v0.14.1...v0.14.2
[0.14.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.14.0...v0.14.1
[0.14.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.13.5...v0.14.0
[0.13.5]: https://github.com/giantswarm/cluster-gcp/compare/v0.13.4...v0.13.5
[0.13.4]: https://github.com/giantswarm/cluster-gcp/compare/v0.13.3...v0.13.4
[0.13.3]: https://github.com/giantswarm/cluster-gcp/compare/v0.13.2...v0.13.3
[0.13.2]: https://github.com/giantswarm/cluster-gcp/compare/v0.13.1...v0.13.2
[0.13.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.13.0...v0.13.1
[0.13.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.8...v0.13.0
[0.12.8]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.7...v0.12.8
[0.12.7]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.6...v0.12.7
[0.12.6]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.5...v0.12.6
[0.12.5]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.4...v0.12.5
[0.12.4]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.3...v0.12.4
[0.12.3]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.2...v0.12.3
[0.12.2]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.1...v0.12.2
[0.12.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.10.2...v0.11.0
[0.10.2]: https://github.com/giantswarm/cluster-gcp/compare/v0.10.1...v0.10.2
[0.10.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.6.2...v0.7.0
[0.6.2]: https://github.com/giantswarm/cluster-gcp/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/giantswarm/cluster-gcp/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/cloud-gcp/compare/v0.1.0...v0.
