package org.microsoft.fruit;

import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import com.datastax.oss.driver.api.core.PagingIterable;

@ApplicationScoped
public class FruitService {

  private final FruitDao dao;

  @Inject
  public FruitService(FruitDao dao) {
    this.dao = dao;
  }

  public void save(Fruit fruit) {
    dao.update(fruit);
  }

  public List<Fruit> get(String id) {
    return dao.findById(id).all();
  }

  public Fruit get(String id, String name) {
    PagingIterable<Fruit> f = dao.findById(id, name);
    return f.one();
  }

  public boolean delete(String id, String name) {
    return dao.deleteById(id, name);
  }
}
