package main

import (
	"context"

	"github.com/alanchchen/grpc-lb-istio/api"
)

func NewServer(name string) *ExampleBackend {
	return &ExampleBackend{
		name: name,
	}
}

type ExampleBackend struct {
	name string
}

func (s *ExampleBackend) Who(ctx context.Context, req *api.WhoRequest) (*api.WhoResponse, error) {
	return &api.WhoResponse{
		Name: s.name,
	}, nil
}
