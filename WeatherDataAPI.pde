// WeatherDataAPI.pde

JSONObject locationData;
JSONObject weatherData;
String apiKey = "3e79d21733beca9a4ceb38097f01fb08";
float lat;
float lon;
String weatherDescription = "";
float temperature = 0;

long unixTimestamp = 1760526000; 
// Using Ip-API Get User Location Data (Need Internet Connection)
void setupLocation() {
  
    String url = "http://ip-api.com/json";
    try {
      locationData = loadJSONObject(url);
      // Get Latitude and Longitude from JSON
      lat = locationData.getFloat("lat");
      lon = locationData.getFloat("lon");
      println("Latitude: " + lat + ", Longitude: " + lon);
    } catch (Exception e) {
      println("Fail to load location data.");
      e.printStackTrace();
      lat = 0;
      lon = 0;
    }
  }
// Using OpenWeatherMap-API Get Weather Data (Need Internet Connection)
String setupWeather() {
    setupLocation();
    String url = "https://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&appid=" + apiKey + "&units=metric&lang=en";
    try {
        weatherData = loadJSONObject(url);
      } catch (Exception e) {
        println("Fail to load weather data.");
        e.printStackTrace();
        return "";
      }
      if (weatherData != null) {
        JSONArray weatherArray = weatherData.getJSONArray("weather"); // Get Weather Description from JSON
        if (weatherArray != null && weatherArray.size() > 0) {
          return weatherArray.getJSONObject(0).getString("description", "");
        }
      }
      return "";
}
