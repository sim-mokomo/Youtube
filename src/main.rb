require './src/output_config'
require './src/video_table'
require './src/playlist'
require './src/channel'
require './src/app_config'
require './src/connection'
require './src/caption_video_table'

def save_undetected_videos
  OutputConfig.new.playlist_configs.each do |config|
    puts "[START] fetching video from #{config.name}"
    videos = PlayList.new(config.id).fetch_videos
    video_records = CaptionVideoTable.new(config.name).filter_undetected_video_record_only(videos)
    video_table = VideoTable.new('./outputs/undetected', file_name)
    video_table.overwrite_save(video_records)
    puts "[END] fetching video from #{config.name}"
  end
end

def check_has_captions
  OutputConfig.new.playlist_configs.each do |config|
    puts "[START] checking caption in #{config.name}"
    caption_video_table = CaptionVideoTable.new(config.name)
    return unless caption_video_table.undetected_video_exists

    videos = caption_video_table.undetected_video_all
    caption_video_table.add_videos_by_caption(videos)
    caption_video_table.reset_undetected_video_table
    puts "[END] checking caption in #{config.name}"
  end
end

def upload_videos_to_spreadsheet
  OutputConfig.new.playlist_configs.each do |config|
    puts "[START] upload to spreadsheet | #{config.name}"
    has_caption_video_table = VideoTable.new('./outputs/has_caption', file_name)
    return if has_caption_video_table.empty

    connection = Connection.new
    connection.post_json_request(
      AppConfig.new.gas_api_endpoint,
      connection.create_request_object(config.name, has_caption_video_table.records)
    )
  end
end

config = AppConfig.new
config.youtube_api_keys.each do |api_key|
  puts "use youtube api key #{api_key}"
  begin
    save_undetected_videos
    check_has_captions
  rescue StandardError => e
    puts e.class
    puts e.message
  end
  config.increment_api_key_index
end
config.reset_api_key_idnex
upload_videos_to_spreadsheet
