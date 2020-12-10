package spec

// Order holds stuff
type Order struct {
	ID          string `json:"id"`
	Product     string `json:"product"`
	Description string `json:"description"`
	Items       int    `json:"items"`
}

// OrderService defines core CRUD methods a order service should have
type OrderService interface {
	Get(string) (*Order, error)
	Create(*Order) (*Order, error)
	Delete(string) error
	Find(string) ([]Order, error)
}
