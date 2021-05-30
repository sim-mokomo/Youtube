require 'google/apis/youtube_v3'
require 'src/config'

class YoutubeService
  attr_reader :service

  def initialize
    config = Config.new
    @service = Google::Apis::YoutubeV3::YouTubeService.new
    @service.key = config.youtube_api_key
  end
end
