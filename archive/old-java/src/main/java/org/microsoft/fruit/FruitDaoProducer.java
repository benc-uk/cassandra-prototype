package org.microsoft.fruit;

import com.datastax.oss.quarkus.runtime.api.session.QuarkusCqlSession;
import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Produces;
import javax.inject.Inject;

public class FruitDaoProducer {

  private final FruitDao fruitDao;
  // private final FruitDaoReactive fruitDaoReactive;

  @Inject
  public FruitDaoProducer(QuarkusCqlSession session) {
    // create a mapper
    FruitMapper mapper = new FruitMapperBuilder(session).build();
    // instantiate our Daos
    fruitDao = mapper.fruitDao();
    // fruitDaoReactive = mapper.fruitDaoReactive();
  }

  @Produces
  @ApplicationScoped
  FruitDao produceFruitDao() {
    return fruitDao;
  }

  // @Produces
  // @ApplicationScoped
  // FruitDaoReactive produceFruitDaoReactive() {
  // return fruitDaoReactive;
  // }
}
