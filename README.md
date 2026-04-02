# IBM Db2 LUW Connector (ibm-db2-luw-connector)

The IBM Db2 LUW Connector provides a JDBC driver integration for IBM Db2 (LUW) for Axon Ivy. It implements the ch.ivyteam.ivy.db.jdbc.spi.JdbcConnector SPI so Axon Ivy can load the DB2 driver from this Ivy project and open JDBC connections via the standard JDBC DriverManager.

Key features
- Implements the Axon Ivy JdbcConnector SPI for Db2 LUW (Db2 for Linux/Unix/Windows).
- Registers and deregisters the IBM DB2 JDBC driver dynamically with DriverManager to support deployment and upgrades.
- Provides DriverInfo metadata (name: "Db2 LUW", database: "Db2 for LUW") and a default configurator (server port 50000).
- Simple API to open JDBC connections via DriverManager.getConnection(url, properties).
- Packaged as an IAR for direct Axon Ivy deployment.

Exposed callable subprocesses / public API
- Processes: none exposed by the main module. (The demo module provides callable subprocesses; see Demo.)

- Java SPI (com.axonivy.connector.ibm.db2.luw.IbmDb2LuwJdbcConnector):
  - info() : DriverInfo
  - register() : Driver
  - deregister(Driver driver) : void
  - open(String connectionUrl, Properties properties) : Connection

## Demo

A demo module (ibm-db2-luw-connector-demo) demonstrates typical user flows. The demo contains simple processes and a docker compose that starts a local Db2 instance for testing.

Demo processes (examples):
- createTable — request-start process that invokes the callable subprocess ensureTableExists and ensures the Db2Test table exists.
- write — request-start process that ensures table exists and writes a sample row (NAME="Hello") into DB2TEST.
- read — request-start process that ensures table exists and executes a query against DB2TEST, returning a recordset.

Demo quick workflow
1. Start the demo Db2 container:
   cd ibm-db2-luw-connector-demo/docker && docker compose up
   (The compose file exposes port 50000 and uses DBNAME=testdb, user db2inst1 with password 'password' for local testing.)
2. Build the project to create IARs:
   mvn -DskipTests package
3. Import/deploy the generated IARs into Axon Ivy (ibm-db2-luw-connector and ibm-db2-luw-connector-demo), or use the product installers defined in ibm-db2-luw-connector-product/product.json.
4. Run the demo processes in Axon Ivy: createTable -> write -> read.

Notes:
- The demo callable subprocess ensureTableExists:call() creates the table using:
  CREATE TABLE Db2Test ( Name VARCHAR(250) NOT NULL )
- The demo contains a compose.yaml at ibm-db2-luw-connector-demo/docker/compose.yaml intended for local evaluation only.

## Setup

Prerequisites
- Axon Ivy 13.1 or later (project parent: ivy-project-parent 13.1.0).
- IBM Db2 LUW server reachable from the Axon Ivy runtime.
- IBM Db2 JCC JDBC driver (com.ibm.db2:jcc:12.1.0.0). Due to IBM licensing the driver may not be available from public Maven registries and must be obtained and installed in your artifact repository or placed on the Axon Ivy server classpath.

Configuration
- JDBC URL format: `jdbc:db2://<host>:<port>/<database>` (default port: 50000).
  Example (demo): `jdbc:db2://localhost:50000/testdb`
- Demo credentials (from docker/compose.yaml): user `db2inst1`, password `password` (local testing only).
- Review or add runtime variables in `ibm-db2-luw-connector/config/variables.yaml` if your environment requires them. The product module references this file during assembly.

Build & packaging
- Build the repository from the root:
  mvn -DskipTests package
- The product module (ibm-db2-luw-connector-product) assembles a distributable zip and copies README and variables into the target during the build.

Security & licensing
- The IBM Db2 JDBC driver is subject to IBM licensing. Ensure you comply with the license when obtaining and installing the driver.
- Demo credentials and the compose file are for local evaluation only and must not be used in production.

Support
- Source repository: https://github.com/axonivy-market/ibm-db2-luw
- For issues or questions, open an issue on the GitHub repository.
