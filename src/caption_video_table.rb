class CaptionVideoTable
  attr_reader :file_name,
              :no_caption_table,
              :has_caption_table,
              :undetected_caption_table

  # @param [String] file_name
  def initialize(file_name)
    @file_name = file_name
    @has_caption_table = VideoTable.new('./outputs/has_caption', @file_name)
    @no_caption_table = VideoTable.new('./outputs/no_caption', @file_name)
    @undetected_caption_table = VideoTable.new('./outputs/undetected', @file_name)
  end

  # @param [Array<Video>] source_videos
  def filter_undetected_video_record_only(source_videos)
    already_checked_video_records = checked_video_record_all
    source_videos
      .map { |x| VideoRecord.new(x.video_id, x.title) }
      .filter { |x| already_checked_video_records.all? { |y| y.video_id != x.video_id } }
  end

  # @return [Array<VideoRecord>]
  def checked_video_record_all
    already_checked_video_records = []
    already_checked_video_records.concat(@has_caption_table.records)
    already_checked_video_records.concat(@no_caption_table.records)
    already_checked_video_records
  end

  # @return [Array<Video>]
  def undetected_video_all
    @undetected_caption_table.records.map do |x|
      Video.new(x.video_id, x.title)
    end
  end

  # @return [Boolean]
  def undetected_video_exists
    undetected_video_all.length.positive?
  end

  # @param [Array<Video>] videos
  def add_videos_by_caption(videos)
    videos.each do |x|
      add_video_by_caption(x)
    end
  end

  # @param [Video] video
  def add_video_by_caption(video)
    record = VideoRecord.new(video.video_id, video.title)
    if video.contain_language_caption(%w[ja en])
      puts "[PROGRESS] check caption #{video.title} #{video.url} => contain caption"
      @has_caption_table.add_record(record)
      @has_caption_table.save
    else
      puts "[PROGRESS] check caption #{video.title} #{video.url} => not contain caption"
      @no_caption_table.add_record(record)
      @no_caption_table.save
    end
  end

  def reset_undetected_video_table
    @undetected_caption_table.overwrite_save([])
  end
end
