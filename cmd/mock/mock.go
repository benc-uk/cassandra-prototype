// ----------------------------------------------------------------------------
// Copyright (c) Ben Coleman, 2020
// Licensed under the MIT License.
//
// Mock of spec.OrderService
// ----------------------------------------------------------------------------

package mock

import (
	"github.com/benc-uk/cassandra-prototype/cmd/spec"
	"github.com/benc-uk/cassandra-prototype/pkg/problem"
)

// OrderService mock
type OrderService struct {
}

// Fake data
var mockOrder *spec.Order

// MockOrderID is a static order id for testing
const MockOrderID = "820cfc30-929c-4b27-aab7-78e217ca3056"

func init() {
	mockOrder = &spec.Order{
		ID:          MockOrderID,
		Product:     "A nice hat",
		Description: "I really want lots of hats",
		Items:       42,
	}
}

//
// Get fetches order by ID
//
func (s OrderService) Get(id string) (*spec.Order, error) {
	if id == MockOrderID {
		return mockOrder, nil
	}
	return nil, problem.New("#mock", "not-found", 404, "not found", "orders")
}

//
// Create new order
//
func (s OrderService) Create(order *spec.Order) (*spec.Order, error) {
	return mockOrder, nil
}

//
// Delete an order
//
func (s OrderService) Delete(id string) error {
	return nil
}

//
// Find all orders
//
func (s OrderService) Find(query string) ([]spec.Order, error) {
	orders := make([]spec.Order, 0)
	orders = append(orders, *mockOrder)
	orders = append(orders, *mockOrder)
	return orders, nil
}

//
// HealthCheck the service
//
func (s OrderService) HealthCheck() bool {
	return true
}
