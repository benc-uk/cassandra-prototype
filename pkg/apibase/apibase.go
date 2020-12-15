// ----------------------------------------------------------------------------
// Copyright (c) Ben Coleman, 2020
// Licensed under the MIT License.
//
// Base API that all services implement and extend
// ----------------------------------------------------------------------------

package apibase

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"runtime"

	"github.com/benc-uk/cassandra-prototype/pkg/problem"
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Base holds a standard set of values for all services & APIs
type Base struct {
	ServiceName string
	Healthy     bool
	Version     string
	BuildInfo   string
	Router      *mux.Router
}

//
// New creates and returns a new Base API instance
//
func New(name, ver, info string, healthy bool, rootRouter *mux.Router) *Base {
	base := &Base{
		ServiceName: name,
		Healthy:     healthy,
		Version:     ver,
		BuildInfo:   info,
		// This is a subrouter for this service, e.g. `/api/users` or `/api/cheese`
		Router: rootRouter.PathPrefix("/api/" + name).Subrouter(),
	}

	// Simple body-less health endpoints
	rootRouter.HandleFunc("/healthz", base.HealthCheck)
	rootRouter.HandleFunc("/api/healthz", base.HealthCheck)

	// Status & debug details
	rootRouter.HandleFunc("/status", base.Status)
	rootRouter.HandleFunc("/api/status", base.Status)

	// Add middleware for logging (only on service API)
	base.Router.Use(base.loggingMiddleware)

	// Add promhttp metrics handler
	rootRouter.Handle("/metrics", promhttp.Handler())

	durationHistogram := promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name:        "response_duration_seconds",
		Help:        "A histogram of request latencies.",
		Buckets:     []float64{.001, .01, .1, .2, .5, 1, 2, 5},
		ConstLabels: prometheus.Labels{"handler": name},
	}, []string{"method"})

	// Add middleware for tracking metrics on service API
	base.Router.Use(func(next http.Handler) http.Handler {
		return base.metricMiddleware(next, durationHistogram)
	})

	return base
}

func (api *Base) updateHealth(healthy bool) {
	api.Healthy = healthy
}

//
// HealthCheck - Simple health check endpoint, returns 204 when healthy
//
func (api *Base) HealthCheck(resp http.ResponseWriter, req *http.Request) {
	if api.Healthy {
		resp.WriteHeader(http.StatusNoContent)
		return
	}
	resp.WriteHeader(http.StatusServiceUnavailable)
}

//
// Status - status information data - Remove if you like
//
func (api *Base) Status(resp http.ResponseWriter, req *http.Request) {
	type status struct {
		Service    string `json:"service"`
		Healthy    bool   `json:"healthy"`
		Version    string `json:"version"`
		BuildInfo  string `json:"buildInfo"`
		Hostname   string `json:"hostname"`
		OS         string `json:"os"`
		Arch       string `json:"architecture"`
		CPU        int    `json:"cpuCount"`
		GoVersion  string `json:"goVersion"`
		ClientAddr string `json:"clientAddress"`
		ServerHost string `json:"serverHost"`
	}

	hostname, err := os.Hostname()
	if err != nil {
		hostname = "hostname not available"
	}

	currentStatus := status{
		Service:    api.ServiceName,
		Healthy:    api.Healthy,
		Version:    api.Version,
		BuildInfo:  api.BuildInfo,
		Hostname:   hostname,
		GoVersion:  runtime.Version(),
		OS:         runtime.GOOS,
		Arch:       runtime.GOARCH,
		CPU:        runtime.NumCPU(),
		ClientAddr: req.RemoteAddr,
		ServerHost: req.Host,
	}

	statusJSON, err := json.Marshal(currentStatus)
	if err != nil {
		http.Error(resp, "Failed to get status", http.StatusInternalServerError)
	}

	resp.Header().Add("Content-Type", "application/json")
	resp.Write(statusJSON)
}

//
// Standard CORS settings, no longer used, left for prosperity
//
/*func (api *APIBase) corsMiddleware(handler http.Handler) http.Handler {
	corsMethods := handlers.AllowedMethods([]string{"GET", "POST", "PUT", "DELETE", "OPTIONS"})
	corsOrigins := handlers.AllowedOrigins([]string{"*"})
	return handlers.CORS(corsOrigins, corsMethods)(handler)
}*/

//
// Basic request logging,
//
func (api *Base) loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Invented header to not log this request, lets us ignore things like k8s probes
		noLog := r.Header.Get("No-Log")
		if noLog != "" {
			next.ServeHTTP(w, r)
			return
		}

		// Really simple request logging
		log.Printf("### %s %s", r.Method, r.RequestURI)
		next.ServeHTTP(w, r)
	})
}

//
// Middleware that adds Prometheus metrics to all requests
//
func (api *Base) metricMiddleware(next http.Handler, histVec *prometheus.HistogramVec) http.Handler {

	return promhttp.InstrumentHandlerDuration(histVec, next)
}

//
// Send is a trivial helper for returning JSON over the API
//
func (api *Base) Send(data interface{}, resp http.ResponseWriter) {
	resp.Header().Set("Content-Type", "application/json")
	json, err := json.Marshal(data)
	if err != nil {
		problem.New("#json", "json-marshal", 500, err.Error(), "-").Send(resp)
		return
	}
	resp.Write(json)
}
