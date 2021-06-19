require './src/youtube_service'

class Video
  attr_reader :video_id, :title

  def initialize(video_id, title)
    @video_id = video_id
    @title = title
    @youtube_service = YoutubeService.new
  end

  def url
    "https://www.youtube.com/watch?v=#{@video_id}"
  end

  # @param [Array<String>]
  def contain_language_caption(languages)
    response = @youtube_service.service.list_captions('snippet', @video_id)
    response
      .items
      .filter { |x| languages.any? { |y| y == x.snippet.language } }
      .filter { |x| x.snippet.track_kind != 'asr' }
      .any?
  end
end
