package com.axonivy.connector.ibm.db2.luw.test;

import java.io.File;
import java.time.Duration;

import org.junit.jupiter.api.Test;
import org.testcontainers.containers.ComposeContainer;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmElement;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmProcess;
import ch.ivyteam.ivy.bpm.exec.client.IvyProcessTest;

@IvyProcessTest
@Testcontainers
class TestIbmDb2LuwJdbcConnector {

  @Container
  @SuppressWarnings("resource")
  public final ComposeContainer db2 = new ComposeContainer(new File("../ibm-db2-luw-connector-demo/docker/compose.yaml"))
      .withExposedService("db2-1", 50000)
      .waitingFor("db2-1", Wait.forLogMessage(".*Setup has completed.*", 1).withStartupTimeout(Duration.ofMinutes(10)));

  private static final BpmProcess DATABASE = BpmProcess.path("database");
  private static final BpmElement CREATE_TABLE = DATABASE.elementName("createTable");
  private static final BpmElement WRITE = DATABASE.elementName("write");
  private static final BpmElement READ = DATABASE.elementName("read");

  @Test
  void callProcess(BpmClient bpmClient) {
    bpmClient.start().process(CREATE_TABLE).execute();
    bpmClient.start().process(WRITE).execute();
    bpmClient.start().process(READ).execute();
  }
}
