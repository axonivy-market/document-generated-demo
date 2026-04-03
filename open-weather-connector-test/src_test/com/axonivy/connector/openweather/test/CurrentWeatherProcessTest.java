package com.axonivy.connector.openweather.test;

import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GET_CURRENT_WEATHER_BY_GEOCODE_SIGNATURE;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GET_CURRENT_WEATHER_PROCESS_PATH;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.RESULT_KEY;
import static org.assertj.core.api.Assertions.assertThat;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.TestTemplate;
import org.openweathermap.api.data2_5.client.Current;


import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.ExecutionResult;
import ch.ivyteam.ivy.bpm.error.BpmError;

public class CurrentWeatherProcessTest extends BaseSetup {
	private final Double TEST_LON_VALUE = 40.7484;
	private final Double TEST_LAT_VALUE = -73.9967;

	@TestTemplate
	public void testGetCurrentWeatherByGeoCode_ReturnsCurrentWeather(BpmClient client) throws NoSuchFieldException {
		ExecutionResult result =
				getSubProcessWithNameAndPath(client, GET_CURRENT_WEATHER_PROCESS_PATH, GET_CURRENT_WEATHER_BY_GEOCODE_SIGNATURE)
						.execute(TEST_LON_VALUE, TEST_LAT_VALUE, StringUtils.EMPTY, StringUtils.EMPTY);
		var object = result.data().last().get(RESULT_KEY);
		assertThat(object).isInstanceOf(Current.class);
	}

	@TestTemplate
	public void testGetCurrentWeatherByGeoCode_ThrowsBpmException(BpmClient client) throws NoSuchFieldException {
		try {
			getSubProcessWithNameAndPath(client, GET_CURRENT_WEATHER_PROCESS_PATH, GET_CURRENT_WEATHER_BY_GEOCODE_SIGNATURE)
					.execute(null, null, StringUtils.EMPTY, StringUtils.EMPTY);
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(HttpStatus.SC_BAD_REQUEST);
		}
	}
}
