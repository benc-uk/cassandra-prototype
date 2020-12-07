package org.microsoft.fruit;

import java.util.List;
import java.util.stream.Collectors;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.metrics.MetricUnits;
import org.eclipse.microprofile.metrics.annotation.*;

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

  @GET
  @Path("{name}")
  @Counted(name = "getFruitCounter", description = "Number of get fruit calls")
  @Timed(name = "getFruitTimer",
      description = "A measure of how long it takes to perform the get fruit call",
      unit = MetricUnits.MILLISECONDS)
  public FruitDto getOne(@PathParam("name") String name) {
    Fruit fruit = fruitService.get(STORE_ID, name);
    if (fruit == null) {
      throw new NotFoundException();
    }
    return convertToDto(fruit);
  }

  @POST
  @Counted(name = "addFruitCounter", description = "Number of add fruit calls")
  @Timed(name = "addFruitTimer",
      description = "A measure of how long it takes to perform the add fruit call",
      unit = MetricUnits.MILLISECONDS)
  public FruitDto add(FruitDto fruit) {
    fruitService.save(convertFromDto(fruit));
    return fruit;
  }

  @DELETE
  @Path("{name}")
  @Counted(name = "deleteFruitCounter", description = "Number of delete fruit calls")
  @Timed(name = "deleteFruitTimer",
      description = "A measure of how long it takes to perform the delete fruit call",
      unit = MetricUnits.MILLISECONDS)
  public void delete(@PathParam("name") String name) {
    boolean found = fruitService.delete(STORE_ID, name);
    if (!found) {
      throw new NotFoundException();
    }
  }

  private FruitDto convertToDto(Fruit fruit) {
    return new FruitDto(fruit.getName(), fruit.getDescription());
  }

  private Fruit convertFromDto(FruitDto fruitDto) {
    return new Fruit(STORE_ID, fruitDto.getName(), fruitDto.getDescription());
  }
}
