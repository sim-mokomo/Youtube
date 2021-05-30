require './src/youtube_service'
require './src/video'

class PlayList
  def initialize(playlist_id)
    @playlist_id = playlist_id
    @youtube_service = YoutubeService.new
  end

  def fetch_videos
    response = list_playlist_items(nil)
    videos = create_videos(response)
    return videos if response.next_page_token.nil?

    loop do
      response = list_playlist_items(response.next_page_token)
      videos.concat(create_videos(response))
      break if response.next_page_token.nil?
    end

    videos
  end

  private

  def create_videos(response)
    response.items.map do |x|
      Video.new(
        x.snippet.resource_id.video_id,
        x.snippet.title
      )
    end
  end

  # @return [Array<Google::Apis::YoutubeV3::ListPlaylistItemsResponse>]
  def list_playlist_items(page_token)
    @youtube_service.service.list_playlist_items(
      'snippet',
      playlist_id: @playlist_id,
      max_results: 50,
      page_token: page_token
    )
  end
end
