# DO NOT EDIT. Generated with:
#
#    devctl@5.2.0
#

##@ App

.PHONY: lint-chart
lint-chart: IMAGE := giantswarm/helm-chart-testing:v3.0.0-rc.1
lint-chart: ## Runs ct against the default chart.
	@echo "====> $@"
	rm -rf /tmp/$(APPLICATION)-test
	mkdir -p /tmp/$(APPLICATION)-test/helm
	cp -a ./helm/$(APPLICATION) /tmp/$(APPLICATION)-test/helm/
	architect helm template --dir /tmp/$(APPLICATION)-test/helm/$(APPLICATION)
	docker run -it --rm -v /tmp/$(APPLICATION)-test:/wd --workdir=/wd --name ct $(IMAGE) ct lint --validate-maintainers=false --charts="helm/$(APPLICATION)"
	rm -rf /tmp/$(APPLICATION)-test


ensure-schema-gen:
	@helm schema-gen &>/dev/null || helm plugin install https://github.com/mihaisee/helm-schema-gen.git

.PHONY: schema-gen
schema-gen: ensure-schema-gen ## Generates the values schema file
	@cd helm/cluster-gcp && helm schema-gen values.yaml > values.schema.json

.PHONY: update-chart-deps
update-chart-deps: ## Update chart dependencies to latest (matching) version
	@cd helm/cluster-gcp && \
	sed -i.bk 's/version: \[\[ .Version \]\]/version: 1/' Chart.yaml && \
	helm dependency update && \
	mv Chart.yaml.bk Chart.yaml
