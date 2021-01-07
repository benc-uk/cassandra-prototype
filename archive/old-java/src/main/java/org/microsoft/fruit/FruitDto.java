package org.microsoft.fruit;

public class FruitDto {

  private String name;
  private String description;

  public FruitDto() {
  }

  public FruitDto(String name, String description) {
    this.name = name;
    this.description = description;
  }

  public String getName() {
    return name;
  }

  public String getDescription() {
    return description;
  }
}
