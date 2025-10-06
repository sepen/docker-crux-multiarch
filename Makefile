# ----------------------------
# Config
# ----------------------------
BASE_DIR := $(shell cd $(dir $(realpath $(lastword $(MAKEFILE_LIST)))) && pwd)
IMAGE_NAME ?= sepen/crux-multiarch
PLATFORMS ?= linux/amd64 linux/arm64 linux/arm/v7
FOLDERS := 3.7 3.8
LATEST := 3.8

# Detect docker or podman
HAVE_DOCKER := $(shell command -v docker 2>/dev/null)
HAVE_PODMAN := $(shell command -v podman 2>/dev/null)

ifeq ($(HAVE_DOCKER),)
  ifeq ($(HAVE_PODMAN),)
    $(error Neither docker nor podman found in PATH)
  else
    ENGINE := podman
  endif
else
  ENGINE := docker
endif

# ----------------------------
# Helpers
# ----------------------------
iso2tar = \
	ISO_FILE=$1; \
	TAR_FILE=$$(basename $$ISO_FILE .iso).tar; \
	EXTRACT_DIR=$$(mktemp -d iso2tar.XXXXXX); \
	echo ">> Extracting $$ISO_FILE to $$TAR_FILE"; \
	if bsdtar -tf $$ISO_FILE >/dev/null 2>&1; then \
		bsdtar -C $$EXTRACT_DIR -xf $$ISO_FILE; \
	elif command -v 7z >/dev/null 2>&1; then \
		7z x $$ISO_FILE -o$$EXTRACT_DIR >/dev/null; \
	else \
		echo "ERROR: neither bsdtar nor 7z can extract $$ISO_FILE"; exit 1; \
	fi; \
	tar -cf $$TAR_FILE -C $$EXTRACT_DIR .; \
	rm -rf $$EXTRACT_DIR; \
	echo ">> Created $$TAR_FILE"

# ----------------------------
# Targets
# ----------------------------
.PHONY: all prepare build push manifest clean

all: build push

prepare:
	@for FOLDER in $(FOLDERS); do \
		$(MAKE) -C $(BASE_DIR)/$$FOLDER prepare-targets ; \
	done

# ----------------------------
# Docker Buildx
# ----------------------------
ifeq ($(ENGINE),docker)

build: prepare
	@echo ">> Building multi-arch image (no push)"
	@for FOLDER in $(FOLDERS); do \
		docker buildx build --platform=$(shell echo $(PLATFORMS) | tr ' ' ',') \
			-t $(IMAGE_NAME):$$FOLDER \
			-f $(BASE_DIR)/$$FOLDER/Dockerfile \
			--load \
			$(BASE_DIR)/$$FOLDER ; \
	done

push: prepare
	@echo ">> Building and pushing multi-arch image"
	@for FOLDER in $(FOLDERS); do \
		if [ "$$FOLDER" = "$(LATEST)" ]; then \
			docker buildx build --platform=$(shell echo $(PLATFORMS) | tr ' ' ',') \
				-t $(IMAGE_NAME):$$FOLDER \
				-t $(IMAGE_NAME):latest \
				-f $(BASE_DIR)/$$FOLDER/Dockerfile \
				--push \
				$(BASE_DIR)/$$FOLDER ; \
		else \
			docker buildx build --platform=$(shell echo $(PLATFORMS) | tr ' ' ',') \
				-t $(IMAGE_NAME):$$FOLDER \
				-f $(BASE_DIR)/$$FOLDER/Dockerfile \
				--push \
				$(BASE_DIR)/$$FOLDER ; \
		fi ; \
	done

manifest:
	@for FOLDER in $(FOLDERS); do \
		docker buildx imagetools inspect $(IMAGE_NAME):$$FOLDER ; \
	done

clean:
	@echo "Nothing to clean for Docker Buildx"

endif


# ----------------------------
# Podman multi-arch
# ----------------------------
ifeq ($(ENGINE),podman)

build: prepare
	@echo ">> Building multi-arch image with Podman"
	@for FOLDER in $(FOLDERS); do \
		echo ">> Remove previous images and manifests"; \
		podman rmi -f $(IMAGE_NAME):$$FOLDER || true ; \
		podman manifest rm $(IMAGE_NAME):$$FOLDER || true ; \
		echo ">> Create an empty manifest" ; \
		podman manifest create $(IMAGE_NAME):$$FOLDER ; \
		echo ">> Build and add each platform to the manifest" ; \
		for PLATFORM in $(PLATFORMS); do \
			echo ">> Building for $$PLATFORM"; \
			podman build --platform $$PLATFORM \
				--manifest $(IMAGE_NAME):$$FOLDER \
				-f $(BASE_DIR)/$$FOLDER/Dockerfile \
				$(BASE_DIR)/$$FOLDER ; \
		done ; \
	done

push:
	@for FOLDER in $(FOLDERS); do \
		if [ "$$FOLDER" = "$(LATEST)" ]; then \
			echo ">> Pushing manifest $(IMAGE_NAME):$$FOLDER and latest to Docker Hub"; \
			podman tag $(IMAGE_NAME):$$FOLDER $(IMAGE_NAME):latest ; \
			podman manifest push --all $(IMAGE_NAME):$$FOLDER \
				docker://docker.io/$(IMAGE_NAME):$$FOLDER ; \
			podman manifest push --all $(IMAGE_NAME):latest \
				docker://docker.io/$(IMAGE_NAME):latest ; \
		else \
			echo ">> Pushing manifest $(IMAGE_NAME):$$FOLDER to Docker Hub"; \
			podman manifest push --all $(IMAGE_NAME):$$FOLDER \
				docker://docker.io/$(IMAGE_NAME):$$FOLDER ; \
		fi ; \
	done

manifest:
	@for FOLDER in $(FOLDERS); do \
		echo ">> Inspecting manifest $(IMAGE_NAME):$$FOLDER"; \
		podman manifest inspect $(IMAGE_NAME):$$FOLDER | jq . ; \
	done

clean:
	@for FOLDER in $(FOLDERS); do \
		podman rmi -f $(IMAGE_NAME):$$FOLDER || true ; \
		podman manifest rm $(IMAGE_NAME):$$FOLDER || true ; \
	done

endif
