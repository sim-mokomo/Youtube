require 'json'

class Config
  attr_reader :youtube_api_keys

  def initialize
    File.open('config.json') do |file|
      json = JSON.parse(file.read)
      @youtube_api_keys = json['youtube-api-keys']
    end
  end
end
