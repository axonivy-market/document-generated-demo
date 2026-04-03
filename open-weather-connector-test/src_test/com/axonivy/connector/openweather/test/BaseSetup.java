package com.axonivy.connector.openweather.test;

import java.io.IOException;
import java.util.List;
import java.util.Properties;

import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.extension.ExtensionContext;

import com.axonivy.utils.e2etest.context.MultiEnvironmentContextProvider;
import com.axonivy.utils.e2etest.utils.E2ETestUtils;

import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.element.BpmProcess;
import ch.ivyteam.ivy.bpm.engine.client.sub.SubRequestBuilder;
import ch.ivyteam.ivy.bpm.exec.client.IvyProcessTest;
import ch.ivyteam.ivy.environment.AppFixture;
import ch.ivyteam.ivy.environment.Ivy;

@IvyProcessTest(enableWebServer = true)
@ExtendWith(MultiEnvironmentContextProvider.class)
public class BaseSetup {
	private static final String APP_ID_KEY = "appId";
	private static final String FEATURE_SUFFIX = ".Features";
	private static final String REST_CLIENT_PREFIX = "RestClients.";
	private static final String WEATHER_GEO_URL_KEY = "weatherGeoUrl";
	private static final String WEATHER_DATA_URL_KEY = "weatherDataUrl";
	private static final String LOCAL_CREDENTIALS_FILE_PATH = "credentials.properties";
	private static final String OPEN_WEATHER_CONNECTOR_PREFIX = "openWeatherConnector.";
	private static final String JSON_FEATURES = "ch.ivyteam.ivy.rest.client.mapper.JsonFeature";
	private static final String WEATHER_DATA_REST_CLIENT_NAME = "WeatherData (Openweathermap weather API)";
	private static final String GEO_DATA_REST_CLIENT_NAME = "GeocodingCoordinates (Openweathermap geocoding API)";
	private static final String WEATHER_DATA_MOCK_ENDPOINT = "{ivy.app.baseurl}/api/weatherDataMock";
	private static final String WEATHER_GEO_MOCK_ENDPOINT = "{ivy.app.baseurl}/api/weatherGeoMock";

	@BeforeEach
	void beforeEach(ExtensionContext context, AppFixture fixture) {
		E2ETestUtils.determineConfigForContext(context.getDisplayName(), runRealEnv(fixture), runMockEnv(fixture));
	}

	private Runnable runRealEnv(AppFixture fixture) {
		return () -> {
			String appId = System.getProperty(APP_ID_KEY);
			String weatherDataUrl = System.getProperty(WEATHER_DATA_URL_KEY);
			String weatherGeoUrl = System.getProperty(WEATHER_GEO_URL_KEY);

			// Local setup for testing
			if (StringUtils.isAnyBlank(new String[] {appId, weatherDataUrl, weatherGeoUrl})) {
				try (var in = BaseSetup.class.getResourceAsStream(LOCAL_CREDENTIALS_FILE_PATH)) {
					if (in != null) {
						Properties props = new Properties();
						props.load(in);
						appId = props.getProperty(APP_ID_KEY);
						weatherDataUrl = props.getProperty(WEATHER_DATA_URL_KEY);
						weatherGeoUrl = props.getProperty(WEATHER_GEO_URL_KEY);
					}
				} catch (IOException e) {
					Ivy.log().warn("Can't get credential from local file with path: {0}", LOCAL_CREDENTIALS_FILE_PATH);
				}
			}

			fixture.var(OPEN_WEATHER_CONNECTOR_PREFIX + WEATHER_DATA_URL_KEY, weatherDataUrl);
			fixture.var(OPEN_WEATHER_CONNECTOR_PREFIX + WEATHER_GEO_URL_KEY, weatherGeoUrl);
			fixture.var(OPEN_WEATHER_CONNECTOR_PREFIX + APP_ID_KEY, appId);
		};
	}

	private Runnable runMockEnv(AppFixture fixture) {
		return () -> {
			// Disable OAuth feature for mock rest service
			fixture.config(REST_CLIENT_PREFIX + WEATHER_DATA_REST_CLIENT_NAME + FEATURE_SUFFIX, List.of(JSON_FEATURES));
			fixture.config(REST_CLIENT_PREFIX + GEO_DATA_REST_CLIENT_NAME + FEATURE_SUFFIX, List.of(JSON_FEATURES));

			fixture.var(OPEN_WEATHER_CONNECTOR_PREFIX + WEATHER_DATA_URL_KEY, WEATHER_DATA_MOCK_ENDPOINT);
			fixture.var(OPEN_WEATHER_CONNECTOR_PREFIX + WEATHER_GEO_URL_KEY, WEATHER_GEO_MOCK_ENDPOINT);
		};
	}

	public static SubRequestBuilder getSubProcessWithNameAndPath(BpmClient client, String subProcessPath,
			String subProcessName) {
		return client.start().subProcess(BpmProcess.path(subProcessPath).elementName(subProcessName));
	}
}
