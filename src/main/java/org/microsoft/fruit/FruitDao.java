package org.microsoft.fruit;

import com.datastax.oss.driver.api.core.*;
import com.datastax.oss.driver.api.mapper.annotations.*;

@Dao
public interface FruitDao {
  @Update
  void update(Fruit fruit);

  @Select
  PagingIterable<Fruit> findById(String id, String name);

  @Select
  PagingIterable<Fruit> findById(String id);

  @Delete(entityClass = Fruit.class, ifExists = true)
  boolean deleteById(String id, String name);
}
