class GeocodingService
  def self.get_coordinates(location)
    conn = Faraday.new(url: 'http://www.mapquestapi.com')
    response = conn.get("/geocoding/v1/address?key=#{ENV['MAPQUEST_API_KEY']}&location=#{location}")
    json = JSON.parse(response.body)

    latitude = json.dig('results', 0, 'locations', 0, 'latLng', 'lat')
    longitude = json.dig('results', 0, 'locations', 0, 'latLng', 'lng')

    latitude && longitude ? Coordinates.new(latitude:, longitude:) : nil
  end

  def self.fetch_directions(start_location, end_location)
    conn = Faraday.new(url: 'http://www.mapquestapi.com')
    response = conn.get("/directions/v2/route?key=#{ENV['MAPQUEST_API_KEY']}&from=#{start_location}&to=#{end_location}")
    JSON.parse(response.body)
  end
end
