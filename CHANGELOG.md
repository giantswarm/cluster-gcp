# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/giantswarm/cluster-gcp/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/giantswarm/cluster-gcp/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/giantswarm/cluster-gcp/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/cloud-gcp/compare/v0.1.0...v0.
