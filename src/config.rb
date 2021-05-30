require 'json'

class Config
  attr_reader :youtube_api_keys, :gas_api_endpoint

  def initialize
    File.open('config.json') do |file|
      json = JSON.parse(file.read)
      @youtube_api_keys = json['youtube-api-keys']
      @gas_api_endpoint = json['gas-api-endpoint']
    end
  end
end
