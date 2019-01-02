// MIT License
//
// Copyright (c) 2018 Alan Chen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	api "github.com/alanchchen/grpc-lb-istio/api"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

var (
	host   string
	port   int
	repeat int
)

func init() {
	flag.StringVar(&host, "host", "127.0.0.1", "The server host")
	flag.IntVar(&port, "port", 7000, "The server port")
	flag.IntVar(&repeat, "repeat", 1, "Times to call server")
	flag.Parse()
}

func main() {
	// Set up a connection to the server.
	conn, err := grpc.Dial(fmt.Sprintf("%s:%d", host, port),
		grpc.WithInsecure(),
	)
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := api.NewIdentityClient(conn)

	ctx := metadata.NewOutgoingContext(context.Background(), metadata.New(map[string]string{
		"Content-Type": "application/grpc",
	}))

	for i := 0; i < repeat; i++ {
		r, err := c.Who(ctx, &api.WhoRequest{})
		if err != nil {
			log.Printf("%v\n", err)
			continue
		}
		log.Printf("%s\n", r.Name)
	}
}
