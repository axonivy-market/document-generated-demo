package com.axonivy.connector.openweather.test.constant;

public class OpenWeatherCommonConstants {
	public static final String RESULT_KEY = "result";
	public static final String RESULTS_KEY = "results";
	public static final String GET_FORECAST_PROCESS_PATH = "connector/ForecastWeather";
	public static final String GET_AIR_POLLUTION_PROCESS_PATH = "connector/AirPollution";
	public static final String GET_CURRENT_WEATHER_PROCESS_PATH = "connector/CurrentWeather";
	public static final String GEOCODING_LOCATION_PROCESS_PATH = "connector/GeocodingLocation";
	public static final String GEOCODING_LOCATION_REVERSE_SIGNATURE = "reverse(Double,Double,Integer)";
	public static final String GET_AIR_POLLUTION_BY_GEOCODE_SIGNATURE = "getCurrentAirPollution(Double,Double)";
	public static final String GEOCODING_LOCATION_BY_ZIP_CODE_SIGNATURE = "getCoordinatesByZipCode(String,String)";
	public static final String GET_FORECAST_AIR_POLLUTION_BY_GEOCODE_SIGNATURE = "getForecastAirPollution(Double,Double)";
	public static final String GET_CURRENT_WEATHER_BY_GEOCODE_SIGNATURE = "getCurrentWeather(Double,Double,String,String)";
	public static final String GET_FORECAST_BY_GEOCODE_SIGNATURE = "getForecastWeather(Double,Double,Integer,String,String)";
	public static final String GEOCODING_LOCATION_BY_NAME_SIGNATURE = "getCoordinatesByLocationName(String,String,String,Integer)";
	public static final String GET_HISTORICAL_AIR_POLLUTION_BY_GEOCODE_SIGNATURE = "getHistoricalAirPollution(Double,Double,OffsetDateTime,OffsetDateTime)";
}
