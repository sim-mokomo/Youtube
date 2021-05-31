require 'google/apis/youtube_v3'
require './src/app_config'

class YoutubeService
  attr_reader :service

  def initialize
    config = AppConfig.new
    @service = Google::Apis::YoutubeV3::YouTubeService.new
    @service.key = config.current_api_key
  end
end
