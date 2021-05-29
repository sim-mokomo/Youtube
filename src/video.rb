class Video
  attr_reader :video_id, :title

  def initialize(video_id, title)
    @video_id = video_id
    @title = title
    @service = YoutubeService.new
  end

  def url
    "https://www.youtube.com/watch?v=#{@video_id}"
  end

  def contain_language_caption(language)
    response = @service.list_captions('snippet', @video_id)
    response
      .items
      .filter { |x| x.snippet.language == language }
      .filter { |x| x.snippet.track_kind != 'asr' }
      .any?
  end
end
