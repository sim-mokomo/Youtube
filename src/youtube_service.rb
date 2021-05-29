require 'google/apis/youtube_v3'

GOOGLE_API_KEY = ''.freeze

class YoutubeService
  attr_reader :service

  def initialize
    @service = Google::Apis::YoutubeV3::YouTubeService.new
    @service.key = GOOGLE_API_KEY
  end
end
