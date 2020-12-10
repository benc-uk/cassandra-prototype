package impl

import (
	"log"

	"github.com/benc-uk/cassandra-sample/cmd/spec"
	"github.com/benc-uk/cassandra-sample/pkg/env"
	"github.com/benc-uk/cassandra-sample/pkg/problem"
	"github.com/gocql/gocql"
)

// OrderService is a Cassandra backed implementation of OrderService spec
type OrderService struct {
	Session   *gocql.Session
	tableName string
}

//
// NewService creates a new OrderService
//
func NewService() *OrderService {
	// Connect to the Cassandra cluster
	cassandraHosts := env.GetEnvString("CASSANDRA_CLUSTER", "localhost")
	keyspace := env.GetEnvString("CASSANDRA_KEYSPACE", "k1")

	cluster := gocql.NewCluster(cassandraHosts)
	cluster.Keyspace = keyspace
	cluster.Consistency = gocql.Quorum

	log.Printf("### Connecting to Cassandra cluster: %s / %s\n", cassandraHosts, keyspace)
	session, err := cluster.CreateSession()
	if err != nil {
		log.Fatal(err)
	}

	return &OrderService{
		Session:   session,
		tableName: "orders",
	}
}

//
// Get fetches order by ID
//
func (s OrderService) Get(id string) (*spec.Order, error) {
	order := &spec.Order{}
	var uuid gocql.UUID

	if err := s.Session.Query(`SELECT id, product, description, items FROM orders WHERE id = ? LIMIT 1`,
		id).Consistency(gocql.One).Scan(&uuid, &order.Product, &order.Description, &order.Items); err != nil {
		return nil, problem.NewCQLProblem(err, "get-order", "orders")
	}

	order.ID = uuid.String()
	return order, nil
}

//
// Create new order
//
func (s OrderService) Create(order *spec.Order) (*spec.Order, error) {
	uuid, _ := gocql.RandomUUID()
	order.ID = uuid.String()

	if err := s.Session.Query(`INSERT INTO orders (id, product, description, items) VALUES (?, ?, ?, ?)`,
		order.ID, order.Product, order.Description, order.Items).Exec(); err != nil {
		return nil, problem.NewCQLProblem(err, "create-order", "orders")
	}

	order.ID = uuid.String()
	return order, nil
}

//
// Delete an order
//
func (s OrderService) Delete(id string) error {
	uuid, err := gocql.ParseUUID(id)
	if err != nil {
		return problem.NewCQLProblem(err, "delete-order", "orders")
	}

	if err := s.Session.Query(`DELETE from orders WHERE id = ?`,
		uuid).Exec(); err != nil {
		return problem.NewCQLProblem(err, "delete-order", "orders")
	}

	return nil
}

//
// Find all orders
//
func (s OrderService) Find(query string) ([]spec.Order, error) {
	orders := make([]spec.Order, 0)
	iter := s.Session.Query(`SELECT id, product, description, items FROM orders`).Iter()
	for {
		order := &spec.Order{}
		var uuid gocql.UUID

		end := iter.Scan(&uuid, &order.Product, &order.Description, &order.Items)
		if !end {
			break
		}

		order.ID = uuid.String()
		orders = append(orders, *order)
	}

	return orders, nil
}
