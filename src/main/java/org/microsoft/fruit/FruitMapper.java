package org.microsoft.fruit;

import com.datastax.oss.driver.api.mapper.annotations.DaoFactory;
import com.datastax.oss.driver.api.mapper.annotations.Mapper;

@Mapper
public interface FruitMapper {
  @DaoFactory
  FruitDao fruitDao();
}
