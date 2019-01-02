# First stage container
FROM golang:alpine as builder

RUN apk add --no-cache make

ARG GO_PACKAGE
ADD . /go/src/${GO_PACKAGE}
RUN cd /go/src/${GO_PACKAGE} && make && mkdir -p /build/bin && mv build/bin/* /build/bin

# Second stage container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /build/bin/* /usr/local/bin/

# Define your entrypoint or command
# ENTRYPOINT [""]
