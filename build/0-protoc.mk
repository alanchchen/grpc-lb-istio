protoc_version = 3.6.1

ifeq ($(HOST_OS), Darwin)
protoc_suffix = osx
else
ifeq ($(HOST_OS), Linux)
protoc_suffix = linux
else
$(error Unsupported Host OS)
endif
endif

remote_protoc_zip = https://github.com/protocolbuffers/protobuf/releases/download/v$(protoc_version)/protoc-$(protoc_version)-$(protoc_suffix)-x86_64.zip
local_protoc_zip = $(TEMPDIR)/$(notdir $(remote_protoc_zip))

$(local_protoc_zip): $(TEMPDIR)
	@curl -sL $(remote_protoc_zip) -o $(local_protoc_zip)

PROTOC := $(HOSTBIN)/protoc
$(PROTOC): $(local_protoc_zip) $(HOSTBIN)
	@unzip -oXq $(local_protoc_zip) -d $(dir $(HOSTBIN))

PROTOC_INCLUDE_DIR := $(HOSTDIR)/include
