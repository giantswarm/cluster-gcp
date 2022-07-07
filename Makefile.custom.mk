CLUSTER ?= cluster-gcp-acceptance

.PHONY: render
render: architect
	mkdir -p $(shell pwd)/helm/rendered
	cp -r $(shell pwd)/helm/cluster-gcp $(shell pwd)/helm/rendered/
	helm repo add cluster-catalog https://giantswarm.github.io/cluster-catalog
	$(ARCHITECT) helm template --dir $(shell pwd)/helm/rendered/cluster-gcp
	helm dependency build $(shell pwd)/helm/rendered/cluster-gcp

# Install cluster-gcp helm chart, but we don't have the CAPI/CAPG CRDs, so using helm install would fail.
# Instead we template the chart and apply ignoring errors.
.PHONY: render
deploy-rendered-chart: render
	helm template $(shell pwd)/helm/rendered/cluster-gcp --set gcp.project="test-project" | kubectl apply --validate=false -f - || true

.PHONY: create-acceptance-cluster
create-acceptance-cluster: kind
	CLUSTER=$(CLUSTER) ./scripts/ensure-kind-cluster.sh

.PHONY: test-acceptance
test-acceptance: KUBECONFIG=$(HOME)/.kube/$(CLUSTER).yml
test-acceptance: create-acceptance-cluster deploy-rendered-chart ## Run acceptance tests
	./scripts/test.sh

KIND = $(shell pwd)/bin/kind
.PHONY: kind
kind: ## Download kind locally if necessary.
	$(call go-get-tool,$(KIND),sigs.k8s.io/kind@v0.14.0)

ARCHITECT = $(shell pwd)/bin/architect
.PHONY: architect
architect: ## Download architect locally if necessary.
	$(call go-get-tool,$(ARCHITECT),github.com/giantswarm/architect@latest)

# go-get-tool will 'go get' any package $2 and install it to $1.
PROJECT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
define go-get-tool
@[ -f $(1) ] || { \
set -e ;\
TMP_DIR=$$(mktemp -d) ;\
cd $$TMP_DIR ;\
go mod init tmp ;\
echo "Downloading $(2)" ;\
GOBIN=$(PROJECT_DIR)/bin go install $(2) ;\
rm -rf $$TMP_DIR ;\
}
endef

ensure-schema-gen:
	@helm schema-gen --help &>/dev/null || helm plugin install https://github.com/mihaisee/helm-schema-gen.git

.PHONY: schema-gen
schema-gen: ensure-schema-gen ## Generates the values schema file
	@cd helm/cluster-gcp && helm schema-gen values.yaml > values.schema.json

.PHONY: update-chart-deps
update-chart-deps: ## Update chart dependencies to latest (matching) version
	@cd helm/cluster-gcp && \
	sed -i.bk 's/version: \[\[ .Version \]\]/version: 1/' Chart.yaml && \
	helm dependency update && \
	mv Chart.yaml.bk Chart.yaml
