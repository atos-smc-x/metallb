# This is simple makefile for local image build
# Official build is done with jenkinsfile in CI workflow

export CONTROLLER_NAME="controller"
export SPEAKER_NAME="speaker"
export CONTROLLER_IMAGE_NAME="metallb-${CONTROLLER_NAME}"
export SPEAKER_IMAGE_NAME="metallb-${SPEAKER_NAME}"
export IMAGE_TAG="v0.9.3"
export CONTROLLER_TARBALL_NAME=$(shell echo ${CONTROLLER_IMAGE_NAME}-${IMAGE_TAG}.tgz|sed 's|/|-|g')
export SPEAKER_TARBALL_NAME=$(shell echo ${SPEAKER_IMAGE_NAME}-${IMAGE_TAG}.tgz|sed 's|/|-|g')

help:
	@echo ""
	@echo "Usage: make COMMAND"
	@echo ""
	@echo "metallb makefile"
	@echo ""
	@echo "Commands:"
	@echo "  build        Build images"
	@echo "  save         Save images as tarball"
	@echo ""

build:
	@echo "Building controller binary..."
	CGO_ENABLED=0 go build -o build/$(CONTROLLER_NAME)/$(CONTROLLER_NAME)  go.universe.tf/metallb/$(CONTROLLER_NAME)
	@echo "Building controller container..."
	cp $(CONTROLLER_NAME)/Dockerfile build/$(CONTROLLER_NAME)
	docker build --pull -t $(CONTROLLER_IMAGE_NAME):$(IMAGE_TAG) build/$(CONTROLLER_NAME)
	@echo "Building speaker binary..."
	CGO_ENABLED=0 go build -o build/$(SPEAKER_NAME)/$(SPEAKER_NAME)  go.universe.tf/metallb/$(SPEAKER_NAME)
	@echo "Building speaker container..."
	cp $(SPEAKER_NAME)/Dockerfile build/$(SPEAKER_NAME)
	docker build --pull -t $(SPEAKER_IMAGE_NAME):$(IMAGE_TAG) build/$(SPEAKER_NAME)

save: build
	@echo "Saving images tarball.."
	docker save ${CONTROLLER_IMAGE_NAME}:${IMAGE_TAG} | gzip > ./build/${CONTROLLER_TARBALL_NAME}
	docker save ${SPEAKER_IMAGE_NAME}:${IMAGE_TAG} | gzip > ./build/${SPEAKER_TARBALL_NAME}

.PHONY: build save


