require 'json'

class Config
  attr_reader :youtube_api_keys

  def initialize
    File.open("config.json") do |file|
      json = JSON.load(file)
      @youtube_api_keys = json["youtube-api-keys"]
    end
  end
end