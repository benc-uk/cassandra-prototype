// ----------------------------------------------------------------------------
// Copyright (c) Ben Coleman, 2020
// Licensed under the MIT License.
//
// Main set of tests for orders service and API + OrderService biz logic
// ----------------------------------------------------------------------------

package main

import (
	"io/ioutil"
	"log"
	"testing"

	"github.com/benc-uk/cassandra-prototype/cmd/mock"
	"github.com/benc-uk/cassandra-prototype/pkg/apibase"
	"github.com/benc-uk/cassandra-prototype/pkg/apitests"

	"github.com/gorilla/mux"
)

func TestOrders(t *testing.T) {
	log.SetOutput(ioutil.Discard)

	// Mock of CartService
	mockOrdersSvc := &mock.OrderService{}

	router := mux.NewRouter()
	api := API{
		apibase.New("orders", "ignore", "ignore", true, router),
		mockOrdersSvc,
	}
	api.addRoutes()

	// Use apitest helper to run tests against the HTTP router
	apitests.Run(t, router, testCases)
}

var testCases = []apitests.Test{
	{
		Name:           "get an existing order",
		URL:            "/api/orders/" + mock.MockOrderID,
		Method:         "GET",
		Body:           "",
		CheckBody:      "items",
		CheckBodyCount: 1,
		CheckStatus:    200,
	},
	{
		Name:           "get all orders",
		URL:            "/api/orders",
		Method:         "GET",
		Body:           "",
		CheckBody:      "items",
		CheckBodyCount: 2,
		CheckStatus:    200,
	},
	{
		Name:           "get missing order",
		URL:            "/api/orders/wibble",
		Method:         "GET",
		Body:           "",
		CheckBody:      "",
		CheckBodyCount: 0,
		CheckStatus:    404,
	},
	{
		Name:   "create order",
		URL:    "/api/orders",
		Method: "POST",
		Body: `{
			"product": "Lemon Curd",
			"description": "An order for some delicious lemon curd",
			"items": 2
		}`,
		CheckBody:      "lemon curd",
		CheckBodyCount: 1,
		CheckStatus:    200,
	},
	{
		Name:           "delete order",
		URL:            "/api/orders/wibble",
		Method:         "DELETE",
		Body:           ``,
		CheckBody:      "OK",
		CheckBodyCount: 1,
		CheckStatus:    200,
	},
}
