package main

import (
	"context"

	"github.com/alanchchen/grpc-lb-istio/api"
)

func NewServer(client api.IdentityClient) *ExampleFrontend {
	return &ExampleFrontend{
		client: client,
	}
}

type ExampleFrontend struct {
	client api.IdentityClient
}

func (s *ExampleFrontend) Who(ctx context.Context, req *api.WhoRequest) (*api.WhoResponse, error) {
	return s.client.Who(ctx, req)
}
