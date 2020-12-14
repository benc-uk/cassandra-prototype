// ----------------------------------------------------------------------------
// Copyright (c) Ben Coleman, 2020
// Licensed under the MIT License.
// ----------------------------------------------------------------------------

package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/benc-uk/cassandra-sample/cmd/impl"
	"github.com/benc-uk/cassandra-sample/cmd/spec"
	"github.com/benc-uk/cassandra-sample/pkg/apibase"
	"github.com/benc-uk/cassandra-sample/pkg/env"

	"github.com/gorilla/mux"
	_ "github.com/joho/godotenv/autoload" // Autoloads .env file if it exists
)

// API is an extended version of the apibase wrapping an order service
type API struct {
	*apibase.Base
	service spec.OrderService
}

var (
	healthy     = true               // Simple health flag
	version     = "0.0.1"            // App version number, set at build time with -ldflags "-X 'main.version=1.2.3'"
	buildInfo   = "No build details" // Build details, set at build time with -ldflags "-X 'main.buildInfo=Foo bar'"
	serviceName = "orders"
	defaultPort = 8080
)

//
// Main entry point, will start HTTP service
//
func main() {
	log.SetOutput(os.Stdout) // Personal preference on log output
	log.Printf("### Cassandra Prototype: %s API v%s starting...", serviceName, version)

	// Port to listen on, change the default as you see fit
	serverPort := env.GetEnvInt("PORT", defaultPort)

	// Use gorilla/mux for routing
	router := mux.NewRouter()

	// Wrapper API with anonymous inner new Base API
	service := impl.NewService()
	api := API{
		apibase.New(serviceName, version, buildInfo, healthy, router),
		service,
	}

	// Add routes for this service (see routes.go)
	api.addRoutes()

	// Root handler
	router.HandleFunc("/", func(resp http.ResponseWriter, req *http.Request) {
		resp.Header().Set("Content-Type", "text/html")
		resp.Write([]byte(`<h3>API server is alive!</h3>`))

		router.Walk(func(route *mux.Route, router *mux.Router, ancestors []*mux.Route) error {
			path, _ := route.GetPathTemplate()
			resp.Write([]byte(fmt.Sprintf("<li><a href='%s'>%s</a></li>", path, path)))
			return nil
		})
	})

	// Polling loop for calling service health checks and updating the API
	go func() {
		for {
			api.Healthy = service.HealthCheck()
			time.Sleep(5 * time.Second)
		}
	}()

	// Start server
	log.Printf("### Server listening on %v\n", serverPort)
	srv := &http.Server{
		Handler:      router,
		Addr:         fmt.Sprintf(":%d", serverPort),
		WriteTimeout: 10 * time.Second,
		ReadTimeout:  10 * time.Second,
		IdleTimeout:  10 * time.Second,
	}

	err := srv.ListenAndServe()
	if err != nil {
		log.Fatal(err.Error())
	}
}
