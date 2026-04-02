package com.axonivy.connector.ibm.db2.luw;

import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

import com.ibm.db2.jcc.DB2Driver;

import ch.ivyteam.ivy.db.jdbc.spi.DriverInfo;
import ch.ivyteam.ivy.db.jdbc.spi.JdbcConnector;

/**
 * <p>Provides the Db2 for LUW (Linux, Unix, Windows) {@link Driver JDBC driver}.</p>
 * <p>Implements the service provider interface (SPI) {@JdbcConnector} that allows Axon Ivy to load the driver from
 * this Ivy Project. The service provider is identified in the service configuration file {@code src/META-INF/services/ch.ivyteam.ivy.db.jdbc.spi.JdbcConnector}.</p>
 * <p>The registration, deregistration and opening of connections needs to be done by a class
 * that is located in the same IvyProject (loaded by the same {@link ClassLoader})
 * as the DB2Driver itself. Otherwise the {@link DriverManager JDBC driver manager}
 * will not work as expected and the methods calls will fail.</p>
 * @since 13.1
 */
public class IbmDb2LuwJdbcConnector implements JdbcConnector {

  private static final DriverInfo INFO = DriverInfo
      .build(DB2Driver.class.getName(), "db2")
      .name("Db2 LUW")
      .database("Db2 for LUW")
      .configurator().server(50000)
      .toDriverInfo();

  @Override
  public DriverInfo info() {
    return INFO;
  }

  @Override
  public Driver register() {
    // Loads the DB2Driver class and registers itself in the JDBC DriverManager
    DB2Driver.getMyClassLoader();
    // Finds the now registered DB2Driver from the JDBC DriverManager and returns it
    return DriverManager
        .drivers()
        .filter(driver -> driver.getClass().equals(DB2Driver.class))
        .findAny()
        .orElse(null);
  }

  @Override
  public void deregister(Driver driver) throws SQLException {
    // Deregisters the given DB2Driver in the DriverManager if it is no longer needed by Axon Ivy.
    // E.g. a new version of the project is built or deployed
    DriverManager.deregisterDriver(driver);
  }

  @Override
  public Connection open(String connectionUrl, Properties properties) throws SQLException {
    // Opens a connection to a Db2 LUW database using the DB2Driver
    return DriverManager.getConnection(connectionUrl, properties);
  }
}
