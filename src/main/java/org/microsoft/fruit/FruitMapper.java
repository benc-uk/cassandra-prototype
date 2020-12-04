package org.microsoft.fruit;

import com.datastax.oss.driver.api.mapper.annotations.*;

@Mapper
public interface FruitMapper {
  @DaoFactory
  FruitDao fruitDao();
}
