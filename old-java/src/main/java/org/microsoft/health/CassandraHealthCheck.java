package org.microsoft.health;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;
import com.datastax.oss.driver.api.core.cql.ResultSet;
import com.datastax.oss.driver.api.core.uuid.Uuids;
import com.datastax.oss.quarkus.runtime.api.session.QuarkusCqlSession;
import javax.inject.Inject;
import java.util.Date;
import java.util.UUID;
import javax.enterprise.context.ApplicationScoped;

@Readiness
@ApplicationScoped
public class CassandraHealthCheck implements HealthCheck {

  static final long NUM_100NS_INTERVALS_SINCE_UUID_EPOCH = 0x01b21dd213814000L;
  QuarkusCqlSession session;

  @Inject
  public CassandraHealthCheck(QuarkusCqlSession sess) {
    session = sess;
  }

  @Override
  // @Inject
  public HealthCheckResponse call() {
    ResultSet nowResult = this.session.execute("SELECT now() FROM system.local;");
    Date date = new Date(getTimeFromUUID(nowResult.one().getUuid(0)));

    ResultSet clusterRes = this.session.execute("SELECT cluster_name FROM system.local;");
    String clusterName = clusterRes.one().getString(0);

    return HealthCheckResponse.named("Cassandra health check").up()
        .withData("systemLocalTime", date.toString()).withData("systemClusterName", clusterName)
        .build();
  }

  public static long getTimeFromUUID(UUID uuid) {
    return (uuid.timestamp() - NUM_100NS_INTERVALS_SINCE_UUID_EPOCH) / 10000;
  }
}
