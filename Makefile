PHONY += all test clean docker docker-push
CURDIR := $(shell pwd)
GOBIN := $(CURDIR)/build/bin
HOSTDIR := $(CURDIR)/build/host
HOSTBIN := $(HOSTDIR)/bin
GOTOOLBIN := $(HOSTBIN)
TEMPDIR := $(CURDIR)/build/tmp
DIRS := \
	$(GOBIN) \
	$(HOSTDIR) \
	$(HOSTBIN) \
	$(TEMPDIR)

HOST_OS := $(shell uname -s)

# Define your docker repository
DOCKER_REPOSITORY ?= alanchen0810
DOCKER_IMAGE ?= $(DOCKER_REPOSITORY)/$(notdir $(CURDIR))
GOPKG := $(subst $(GOPATH)/src/,,$(CURDIR))
REV ?= $(shell git rev-parse --short HEAD 2> /dev/null)

export PATH := $(HOSTBIN):$(PATH)

CURRENT_DOCKER_IMAGE := $(DOCKER_IMAGE):$(REV)
LATEST_DOCKER_IMAGE := $(DOCKER_IMAGE):latest

APPS := $(sort $(notdir $(wildcard ./cmd/*)))
GOTOOLS := $(sort $(notdir $(wildcard ./tools/*)))
PHONY += $(APPS) $(GOTOOLS)

all: $(APPS)

.SECONDEXPANSION:
$(APPS): $(addprefix $(GOBIN)/,$$@)

.SECONDEXPANSION:
$(GOTOOLS): $(addprefix $(HOSTBIN)/,$$@)

$(DIRS) :
	@mkdir -p $@

$(GOBIN)/%: $(GOBIN) FORCE
	@go build -o $@ ./cmd/$(notdir $@)
	@echo "Done building."
	@echo "Run \"$(subst $(CURDIR),.,$@)\" to launch $(notdir $@)."

$(GOTOOLBIN)/%: $(GOTOOLBIN) FORCE
	@go build -o $@ ./tools/$(notdir $@)

include $(wildcard build/*.mk)

PROTOC_INCLUDES := \
	-Ivendor/github.com/golang/protobuf/ptypes/struct \
	-Ivendor/github.com/golang/protobuf/ptypes/empty \
	-Ivendor/github.com/golang/protobuf/descriptor \
	-Ivendor/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
	-I$(PROTOC_INCLUDE_DIR) \
	-I$(GOPATH)/src

PROTOS := $(wildcard api/*.proto)

gen: $(PROTOC) $(GOTOOLS)
	@$(PROTOC) $(PROTOC_INCLUDES) --go_out=plugins=grpc:$(GOPATH)/src $(addprefix $(CURDIR)/,$(PROTOS))

deps:
	@dep ensure

docker:
	@echo $(GOPKG)
	@docker build --build-arg GO_PACKAGE=$(GOPKG) -t $(CURRENT_DOCKER_IMAGE) -t $(LATEST_DOCKER_IMAGE) .

docker-push:
	@docker push $(CURRENT_DOCKER_IMAGE)
	@docker push $(LATEST_DOCKER_IMAGE)

test:
	@go test -v ./...

clean:
	@rm -fr $(DIRS)

distclean:
	@rm -fr $(HOSTBIN) $(GOBIN)

PHONY: help
help:
	@echo  'Generic targets:'
	@echo  '  all                         - Build all targets marked with [*]'
	@for app in $(APPS); do \
		printf "* %s\n" $$app; done
	@echo  ''
	@echo  'Code generation targets:'
	@echo  '  gen                         - Generate code from .proto files'
	@echo  ''
	@echo  'Docker targets:'
	@echo  '  docker                      - Build docker image'
	@echo  '  docker-push                 - Push docker image'
	@echo  ''
	@echo  'Dependency management targets:'
	@echo  '  deps                        - Run dep ensure to update dependencies'
	@echo  ''
	@echo  'Test targets:'
	@echo  '  test                        - Run all tests'
	@echo  ''
	@echo  'Cleaning targets:'
	@echo  '  clean                       - Clean built directory'
	@echo  ''
	@echo  'Execute "make" or "make all" to build all targets marked with [*] '
	@echo  'For further info see the ./README.md file'

.PHONY: $(PHONY)

.PHONY: FORCE
FORCE:
