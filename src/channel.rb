require './src/youtube_service.rb'
require './src/video'

class Channel
  def initialize(channel_id)
    @channel_id = channel_id
    @youtube_service = YoutubeService.new
  end

  def search_videos
    response = list_searches(nil)
    videos = create_videos_from_response(response)
    return videos if response.next_page_token.nil?

    loop do
      response = list_searches(response.next_page_token)
      videos.concat(create_videos_from_response(response))
      break if response.next_page_token.nil?
    end

    videos.filter { |x| !x.video_id.nil? }
  end

  private

  def create_videos_from_response(response)
    response.items.map do |x|
      Video.new(
        x.id.video_id,
        x.snippet.title
      )
    end
  end

  # @return [Array<Google::Apis::YoutubeV3::SearchListsResponse>]
  def list_searches(page_token)
    @youtube_service.service.list_searches(
      'id,snippet',
      channel_id: @channel_id,
      max_results: 50,
      page_token: page_token
    )
  end
end
