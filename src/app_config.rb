require 'json'

class AppConfig
  attr_reader :gas_api_endpoint, :youtube_api_keys

  def initialize
    File.open('app_config.json') do |file|
      json = JSON.parse(file.read)
      @youtube_api_keys = json['youtube-api-keys']
      @gas_api_endpoint = json['gas-api-endpoint']
      @current_api_key_index = 0
    end
  end

  def current_api_key
    @youtube_api_keys[@current_api_key_index]
  end

  def increment_api_key_index
    @current_api_key_index += 1
    @current_api_key_index = @current_api_key_index % @youtube_api_keys.length
  end
end
