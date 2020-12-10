// ----------------------------------------------------------------------------
// Copyright (c) Ben Coleman, 2020
// Licensed under the MIT License.
// ----------------------------------------------------------------------------

package main

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/benc-uk/cassandra-sample/cmd/spec"
	"github.com/benc-uk/cassandra-sample/pkg/problem"
	"github.com/gorilla/mux"
)

//
// All routes we need should be registered here
//
func (api API) addRoutes(router *mux.Router) {
	router.HandleFunc("/api/orders/{id}", api.getOrder).Methods("GET")
	router.HandleFunc("/api/orders", api.newOrder).Methods("POST")
	router.HandleFunc("/api/orders/{id}", api.deleteOrder).Methods("DELETE")
	router.HandleFunc("/api/orders", api.getAll).Methods("GET")
}

//
// Fetch order by id
//
func (api API) getOrder(resp http.ResponseWriter, req *http.Request) {
	vars := mux.Vars(req)
	order, err := api.service.Get(vars["id"])
	if err != nil {
		prob := err.(*problem.Problem)
		prob.Send(resp)
		return
	}

	api.Send(order, resp)
}

//
// Create order
//
func (api API) newOrder(resp http.ResponseWriter, req *http.Request) {
	cl, _ := strconv.Atoi(req.Header.Get("content-length"))
	if cl <= 0 {
		problem.New("err://body-missing", "Zero length body", 400, "Zero length body", api.ServiceName).Send(resp)
		return
	}

	order := spec.Order{}
	err := json.NewDecoder(req.Body).Decode(&order)
	if err != nil {
		problem.New("err://json-decode", "Malformed user JSON", 400, "JSON could not be decoded", api.ServiceName).Send(resp)
		return
	}

	_, err = api.service.Create(&order)
	if err != nil {
		prob := err.(*problem.Problem)
		prob.Send(resp)
		return
	}

	api.Send(order, resp)
}

//
// Delete order
//
func (api API) deleteOrder(resp http.ResponseWriter, req *http.Request) {
	vars := mux.Vars(req)
	err := api.service.Delete(vars["id"])
	if err != nil {
		(err.(*problem.Problem)).Send(resp)
		return
	}

	api.Send(map[string]string{
		"message": "deleted OK",
	}, resp)
}

//
// Get all orders
//
func (api API) getAll(resp http.ResponseWriter, req *http.Request) {
	orders, err := api.service.Find("")
	if err != nil {
		prob := err.(*problem.Problem)
		prob.Send(resp)
		return
	}

	api.Send(orders, resp)
}
