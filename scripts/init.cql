DROP TABLE IF EXISTS k1.orders;
CREATE KEYSPACE IF NOT EXISTS k1 WITH replication = {'class':'SimpleStrategy', 'replication_factor':1};
CREATE TABLE k1.orders(id UUID, product text, description text, items int, PRIMARY KEY(id));
