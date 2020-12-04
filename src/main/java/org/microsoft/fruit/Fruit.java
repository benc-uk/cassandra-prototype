package org.microsoft.fruit;

import com.datastax.oss.driver.api.mapper.annotations.ClusteringColumn;
import com.datastax.oss.driver.api.mapper.annotations.Entity;
import com.datastax.oss.driver.api.mapper.annotations.PartitionKey;

@Entity
public class Fruit {

  @PartitionKey
  private String storeId;
  @ClusteringColumn
  private String name;
  private String description;

  public Fruit() {
  }

  public Fruit(String storeId, String name, String description) {
    this.storeId = storeId;
    this.name = name;
    this.description = description;
  }

  /** @return The store id for which this fruit was defined. */
  public String getStoreId() {
    return storeId;
  }

  public void setStoreId(String storeId) {
    this.storeId = storeId;
  }

  /** @return The fruit name. */
  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  /** @return The fruit description. */
  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }
}
