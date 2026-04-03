package com.axonivy.connector.openweather.test;

import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GEOCODING_LOCATION_BY_NAME_SIGNATURE;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GEOCODING_LOCATION_BY_ZIP_CODE_SIGNATURE;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GEOCODING_LOCATION_PROCESS_PATH;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.GEOCODING_LOCATION_REVERSE_SIGNATURE;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.RESULTS_KEY;
import static com.axonivy.connector.openweather.test.constant.OpenWeatherCommonConstants.RESULT_KEY;
import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.TestTemplate;
import org.openweathermap.api.geo1_0.client.GeoLocation;

import ch.ivyteam.ivy.bpm.engine.client.BpmClient;
import ch.ivyteam.ivy.bpm.engine.client.ExecutionResult;
import ch.ivyteam.ivy.bpm.error.BpmError;

public class GeocodingLocationProcessTest extends BaseSetup {
	private final Double TEST_LON_VALUE = 40.7484;
	private final Double TEST_LAT_VALUE = -73.9967;
	private final String TEST_ZIPCODE_VALUE = "10001";

	@TestTemplate
	public void testGeocodingByName_ReturnsListOfGeoLocations(BpmClient client) throws NoSuchFieldException {
		ExecutionResult result =
				getSubProcessWithNameAndPath(client, GEOCODING_LOCATION_PROCESS_PATH, GEOCODING_LOCATION_BY_NAME_SIGNATURE)
						.execute("London", StringUtils.EMPTY, StringUtils.EMPTY, 1);
		var object = result.data().last().get(RESULTS_KEY);
		assertThat(object).isInstanceOf(List.class);
		var objects = (ArrayList<?>) object;
		assertThat(objects).isNotEmpty();
		assertThat(objects.get(0)).isInstanceOf(GeoLocation.class);
	}

	@TestTemplate
	public void testGeocodingByName_ThrowsBpmException(BpmClient client) throws NoSuchFieldException {
		try {
			getSubProcessWithNameAndPath(client, GEOCODING_LOCATION_PROCESS_PATH, GEOCODING_LOCATION_BY_NAME_SIGNATURE)
					.execute(StringUtils.EMPTY, StringUtils.EMPTY, StringUtils.EMPTY, 1);
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(HttpStatus.SC_BAD_REQUEST);
		}
	}

	@TestTemplate
	public void testGeocodingByZip_ReturnsGeoLocation(BpmClient client) throws NoSuchFieldException {
		ExecutionResult result =
				getSubProcessWithNameAndPath(client, GEOCODING_LOCATION_PROCESS_PATH, GEOCODING_LOCATION_BY_ZIP_CODE_SIGNATURE)
						.execute(TEST_ZIPCODE_VALUE, StringUtils.EMPTY);
		var object = result.data().last().get(RESULT_KEY);
		assertThat(object).isInstanceOf(GeoLocation.class);
	}

	@TestTemplate
	public void testGeocodingByZip_ThrowsBpmException(BpmClient client) throws NoSuchFieldException {
		try {
			getSubProcessWithNameAndPath(client, GEOCODING_LOCATION_PROCESS_PATH, GEOCODING_LOCATION_BY_ZIP_CODE_SIGNATURE)
					.execute(StringUtils.EMPTY, StringUtils.EMPTY);
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(HttpStatus.SC_BAD_REQUEST);
		}
	}

	@TestTemplate
	public void testReverse_ReturnsListOfGeoLocations(BpmClient client) throws NoSuchFieldException {
		ExecutionResult result =
				getSubProcessWithNameAndPath(client, GEOCODING_LOCATION_PROCESS_PATH, GEOCODING_LOCATION_REVERSE_SIGNATURE)
						.execute(TEST_LON_VALUE, TEST_LAT_VALUE, 1);
		var object = result.data().last().get(RESULTS_KEY);
		assertThat(object).isInstanceOf(List.class);
		var objects = (ArrayList<?>) object;
		assertThat(objects).isNotEmpty();
		assertThat(objects.get(0)).isInstanceOf(GeoLocation.class);
	}

	@TestTemplate
	public void testReverse_ThrowsBpmException(BpmClient client) throws NoSuchFieldException {
		try {
			getSubProcessWithNameAndPath(client, GEOCODING_LOCATION_PROCESS_PATH, GEOCODING_LOCATION_REVERSE_SIGNATURE)
					.execute(null, null, 1);
		} catch (BpmError e) {
			assertThat(e.getHttpStatusCode()).isEqualTo(HttpStatus.SC_BAD_REQUEST);
		}
	}
}
