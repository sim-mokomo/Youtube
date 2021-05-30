require 'json'

class Config
  attr_reader :gas_api_endpoint

  def initialize
    File.open('config.json') do |file|
      json = JSON.parse(file.read)
      @youtube_api_keys = json['youtube-api-keys']
      @gas_api_endpoint = json['gas-api-endpoint']
      @use_youtube_api_index = json['use-youtube-api-index']
    end
  end

  def youtube_api_key
    @youtube_api_keys[@use_youtube_api_index]
  end
end
