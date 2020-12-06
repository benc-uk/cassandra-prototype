package org.microsoft.fruit;

import java.util.List;
import java.util.stream.Collectors;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.metrics.MetricUnits;
import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.metrics.annotation.Timed;

/**
 * A REST resource exposing endpoints for creating and retrieving {@link Fruit} objects in the
 * database, leveraging the {@link FruitService} component.
 */
@Path("/fruits")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class FruitResource {

  private static final String STORE_ID = "acme";

  @Inject
  FruitService fruitService;

  @GET
  @Counted(name = "getAllFruitCounter", description = "Number of getAll fruit calls")
  @Timed(name = "getAllFruitTimer",
      description = "A measure of how long it takes to perform the getAll fruit call",
      unit = MetricUnits.MILLISECONDS)
  public List<FruitDto> getAll() {
    return fruitService.get(STORE_ID).stream().map(this::convertToDto).collect(Collectors.toList());
  }

  @POST
  @Counted(name = "addFruitCounter", description = "Number of add fruit calls")
  @Timed(name = "addFruitTimer",
      description = "A measure of how long it takes to perform the add fruit call",
      unit = MetricUnits.MILLISECONDS)
  public void add(FruitDto fruit) {
    fruitService.save(convertFromDto(fruit));
  }

  private FruitDto convertToDto(Fruit fruit) {
    return new FruitDto(fruit.getName(), fruit.getDescription());
  }

  private Fruit convertFromDto(FruitDto fruitDto) {
    return new Fruit(STORE_ID, fruitDto.getName(), fruitDto.getDescription());
  }
}
