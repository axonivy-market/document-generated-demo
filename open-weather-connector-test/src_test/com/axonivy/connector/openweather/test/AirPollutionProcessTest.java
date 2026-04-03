package com.axonivy.connector.openweather.test;

import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GET_AIR_POLLUTION_BY_GEOCODE_SIGNATURE;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GET_AIR_POLLUTION_PROCESS_PATH;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GET_FORECAST_AIR_POLLUTION_BY_GEOCODE_SIGNATURE;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GET_HISTORICAL_AIR_POLLUTION_BY_GEOCODE_SIGNATURE;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.RESULT_KEY;
import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.OffsetDateTime;

import org.apache.http.HttpStatus;
import org.junit.jupiter.api.TestTemplate;
import org.openweathermap.api.data2_5.client.AirPollution;

import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.ExecutionResult;
import ch.ivyteam.ivy.bpm.error.BpmError;

public class AirPollutionProcessTest extends BaseSetup {
	private final Double TEST_LON_VALUE = 40.7484;
	private final Double TEST_LAT_VALUE = -73.9967;

	@TestTemplate
	void testGetAirPollutionByGeoCode_ReturnsAirPollution(BpmClient client) throws NoSuchFieldException {
		ExecutionResult result =
				getSubProcessWithNameAndPath(client, GET_AIR_POLLUTION_PROCESS_PATH, GET_AIR_POLLUTION_BY_GEOCODE_SIGNATURE)
						.execute(TEST_LON_VALUE, TEST_LAT_VALUE);
		var object = result.data().last().get(RESULT_KEY);
		assertThat(object).isInstanceOf(AirPollution.class);
	}

	@TestTemplate
	void testGetAirPollutionByGeoCode_ThrowsBpmException(BpmClient client) throws NoSuchFieldException {
		try {
			getSubProcessWithNameAndPath(client, GET_AIR_POLLUTION_PROCESS_PATH, GET_AIR_POLLUTION_BY_GEOCODE_SIGNATURE)
					.execute(null, null);
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(HttpStatus.SC_BAD_REQUEST);
		}
	}

	@TestTemplate
	void testGetForecastAirPollutionByGeoCode_ReturnsAirPollution(BpmClient client) throws NoSuchFieldException {
		ExecutionResult result = getSubProcessWithNameAndPath(client, GET_AIR_POLLUTION_PROCESS_PATH,
				GET_FORECAST_AIR_POLLUTION_BY_GEOCODE_SIGNATURE).execute(TEST_LON_VALUE, TEST_LAT_VALUE);
		var object = result.data().last().get(RESULT_KEY);
		assertThat(object).isInstanceOf(AirPollution.class);
	}

	@TestTemplate
	void testGetForecastAirPollutionByGeoCode_ThrowsBpmException(BpmClient client) throws NoSuchFieldException {
		try {
			getSubProcessWithNameAndPath(client, GET_AIR_POLLUTION_PROCESS_PATH,
					GET_FORECAST_AIR_POLLUTION_BY_GEOCODE_SIGNATURE).execute(null, null);
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(HttpStatus.SC_BAD_REQUEST);
		}
	}

	@TestTemplate
	void testGetHistoricalAirPollutionByGeoCode_ReturnsAirPollution(BpmClient client) throws NoSuchFieldException {
		OffsetDateTime now = OffsetDateTime.now();
		OffsetDateTime twoDaysLater = now.plus(Duration.ofDays(2));
		ExecutionResult result = getSubProcessWithNameAndPath(client, GET_AIR_POLLUTION_PROCESS_PATH,
				GET_HISTORICAL_AIR_POLLUTION_BY_GEOCODE_SIGNATURE).execute(TEST_LON_VALUE, TEST_LAT_VALUE, now, twoDaysLater);
		var object = result.data().last().get(RESULT_KEY);
		assertThat(object).isInstanceOf(AirPollution.class);
	}

	@TestTemplate
	void testGetHistoricalAirPollutionByGeoCode_ThrowsBpmExceptionCanNotGeo(BpmClient client)
			throws NoSuchFieldException {
		OffsetDateTime now = OffsetDateTime.now();
		OffsetDateTime twoDaysLater = now.plus(Duration.ofDays(2));
		try {
			getSubProcessWithNameAndPath(client, GET_AIR_POLLUTION_PROCESS_PATH,
					GET_HISTORICAL_AIR_POLLUTION_BY_GEOCODE_SIGNATURE).execute(null, null, now, twoDaysLater);
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(HttpStatus.SC_BAD_REQUEST);
		}
	}

	@TestTemplate
	void testGetHistoricalAirPollutionByGeoCode_ThrowsBpmExceptionStartMoreThanEnd(BpmClient client)
			throws NoSuchFieldException {
		OffsetDateTime now = OffsetDateTime.now();
		OffsetDateTime twoDaysLater = now.plus(Duration.ofDays(2));
		try {
			getSubProcessWithNameAndPath(client, GET_AIR_POLLUTION_PROCESS_PATH,
					GET_HISTORICAL_AIR_POLLUTION_BY_GEOCODE_SIGNATURE).execute(TEST_LON_VALUE, TEST_LAT_VALUE, twoDaysLater, now);
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(HttpStatus.SC_BAD_REQUEST);
		}
	}
}
