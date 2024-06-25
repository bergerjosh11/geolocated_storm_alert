require 'httparty'
require 'twilio-ruby'
require 'dotenv/load'

# Load environment variables from .env file
GEOLOCATION_API_KEY = ENV['GEOLOCATION_API_KEY']
WEATHER_API_KEY = ENV['WEATHER_API_KEY']
TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID']
TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
WHATSAPP_FROM = ENV['WHATSAPP_FROM']
WHATSAPP_TO = ENV['WHATSAPP_TO']

def get_location
  response = HTTParty.post("https://www.googleapis.com/geolocation/v1/geolocate?key=#{GEOLOCATION_API_KEY}", body: {})
  response.parsed_response['location']
end

def get_weather_alerts(lat, lng)
  response = HTTParty.get("https://api.weather.com/v3/wx/alerts/current?apiKey=#{WEATHER_API_KEY}&geocode=#{lat},#{lng}&format=json")
  alerts = response.parsed_response['alerts']
  alerts.select { |alert| alert['eventDescription'].downcase.include?('storm') }
end

def send_whatsapp_message(body)
  client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
  client.messages.create(
    from: WHATSAPP_FROM,
    to: WHATSAPP_TO,
    body: body
  )
end

location = get_location
alerts = get_weather_alerts(location['lat'], location['lng'])

if alerts.any?
  send_whatsapp_message("Storm warning in your area: #{alerts.first['headlineText']}")
else
  puts "No storm warnings in your area."
end
