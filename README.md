# grpc-lb-istio

Go example for gRPC load balancing with Istio

## Introduction

Ａll executables are located at the `cmd` directory.

## Examples

There are 5 examples:

- `frontend`: connect to `backend` and provides public RESTful/gRPC interfaces.
- `backend`: a standalone service.

## Usage

### Development

Build all executables
```bash
$ make all
```

Generate code from protobuf
```bash
$ make gen
```

Clean all executables
```bash
$ make clean
```

Run go test
```bash
$ make test
```

Run dep ensure
```bash
$ make deps
```

### Docker

Build docker image
```bash
$ make docker
```

Push docker image
```bash
$ make docker-push
```

## License

The MIT License
