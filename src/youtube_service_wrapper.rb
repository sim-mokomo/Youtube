require 'google/apis/youtube_v3'

module MokomoGames
  GOOGLE_API_KEY = ''.freeze

  class YoutubeServiceWrapper
    def initialize
      @service = Google::Apis::YoutubeV3::YouTubeService.new
      @service.key = GOOGLE_API_KEY
    end

    def self.create_youtube_url(video_id)
      "https://www.youtube.com/watch?v=#{video_id}"
    end

    def contain_language_caption(language, video_id)
      response = @service.list_captions('snippet', video_id)
      response
        .items
        .filter { |x| x.snippet.language == language }
        .filter { |x| x.snippet.track_kind != 'asr' }
        .any?
    end

    # @return [Array<Google::Apis::YoutubeV3::ListPlaylistItemsResponse>]
    def get_videos_from_playlist(playlist_id, page_token)
      @service
        .list_playlist_items(
          'snippet',
          playlist_id: playlist_id,
          max_results: 50,
          page_token: page_token
        )
    end

    # @return [Array<Google::Apis::YoutubeV3::SearchListsResponse>]
    def get_channel_videos_from_search(channel_id, page_token)
      @service
        .list_searches(
          'id,snippet',
          channel_id: channel_id,
          max_results: 50,
          page_token: page_token
        )
    end
  end
end
