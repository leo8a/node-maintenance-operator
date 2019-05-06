IMAGE_REGISTRY ?= quay.io/kubevirt
IMAGE_TAG ?= latest
OPERATOR_IMAGE ?= node-maintenance-operator
REGISTRY_IMAGE ?= node-maintenance-operator-registry

all: vet fmt container-build container-push
vet:
	go vet ./pkg/... ./cmd/...

fmt:
	go fmt ./pkg/... ./cmd/...

container-build: container-build-operator container-build-registry

container-build-operator:
	docker build -f build/Dockerfile -t $(IMAGE_REGISTRY)/$(OPERATOR_IMAGE):$(IMAGE_TAG) .

container-build-registry:
	docker build -f build/Dockerfile.registry -t $(IMAGE_REGISTRY)/$(REGISTRY_IMAGE):$(IMAGE_TAG) .

container-push: container-push-operator container-push-registry

container-push-operator:
	docker push $(IMAGE_REGISTRY)/$(OPERATOR_IMAGE):$(IMAGE_TAG)

container-push-registry:
	docker push $(IMAGE_REGISTRY)/$(REGISTRY_IMAGE):$(IMAGE_TAG)

manifests:	
	CSV_VERSION=$(IMAGE_TAG) ./hack/release-manifests.sh

cluster-up:
	CLUSTER_NUM_NODES=3 ./cluster/up.sh

cluster-down:
	./cluster/down.sh

cluster-sync:
	./cluster/sync.sh	

cluster-functest:
	./cluster/functest.sh

cluster-clean:
	./cluster/clean.sh		

.PHONY: vet fmt container-build container-push manifests cluster-up cluster-down cluster-sync cluster-functest cluster-clean all
