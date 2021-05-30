require './src/output_config'
require './src/video_table'
require './src/playlist'
require './src/channel'
require './src/config'
require './src/connection'

def save_undetected_videos_process
  output_config = OutputConfig.new
  output_config.playlist_configs.each do |config|
    videos = PlayList.new(config.id).fetch_videos
    save_undetected_video_records(videos, config.name)
  end
  output_config.channel_configs.each do |config|
    unless config.enable
      p "skip channel searching #{config.name}"
      next
    end

    videos = Channel.new(config.id).search_videos
    save_undetected_video_records(videos, config.name)
  end
end

def save_undetected_video_records(videos, file_name)
  puts "[START] fetching video from channel #{file_name}"
  video_records = get_undetected_video_record_only(videos, file_name)
  video_records.each do |record|
    p record
  end
  video_table = VideoTable.new('./outputs/undetected', file_name)
  video_table.overwrite_save(video_records)
  puts "[END] fetching video in #{file_name}"
end

def get_undetected_video_record_only(source_videos, file_name)
  already_checked_video_records = get_checked_video_record_all(file_name)
  source_videos
    .map { |x| VideoRecord.new(x.video_id, x.title) }
    .filter { |x| already_checked_video_records.all? { |y| y.video_id != x.video_id } }
end

def get_checked_video_record_all(file_name)
  has_caption_video_table = VideoTable.new('./outputs/has_caption', file_name)
  no_caption_video_table = VideoTable.new('./outputs/no_caption', file_name)

  already_checked_video_records = []
  already_checked_video_records.concat(has_caption_video_table.records)
  already_checked_video_records.concat(no_caption_video_table.records)
  already_checked_video_records
end

def check_has_captions_process
  output_config = OutputConfig.new
  output_config.playlist_configs.each do |config|
    puts "[START] checking caption in #{config.name}"
    split_to_caption_videos(config.name)
    puts "[END] checking caption in #{config.name}"
  end

  output_config.channel_configs.each do |config|
    puts "[START] checking caption in #{config.name}"
    split_to_caption_videos(config.name)
    puts "[END] checking caption in #{config.name}"
  end
end

def split_to_caption_videos(file_name)
  video_table = VideoTable.new('./outputs/undetected', file_name)
  video_records = get_undetected_video_record_only(video_table.records, file_name)
  return if video_records.length.zero?

  has_caption_video_table = VideoTable.new('./outputs/has_caption', file_name)
  no_caption_video_table = VideoTable.new('./outputs/no_caption', file_name)

  video_records.each do |record|
    video = Video.new(record.video_id, record.title)
    print "[PROGRESS] check caption #{video.title} #{video.url}"
    if video.contain_language_caption(%w[ja en])
      puts ' => contain caption'
      has_caption_video_table.add_record(record)
      has_caption_video_table.save
    else
      puts ' => not contain caption'
      no_caption_video_table.add_record(record)
      no_caption_video_table.save
    end
  end
end

def upload_caption_video_to_spreadsheet_process
  output_config = OutputConfig.new
  output_config.playlist_configs.each do |config|
    upload_caption_video_to_spreadsheet(config.name)
  end
  output_config.channel_configs.each do |config|
    upload_caption_video_to_spreadsheet(config.name)
  end
end

def upload_caption_video_to_spreadsheet(file_name)
  puts "[START] upload to spreadsheet | #{file_name}"
  has_caption_video_table = VideoTable.new('./outputs/has_caption', file_name)
  if has_caption_video_table.empty
    puts "[END] upload to spreadsheet | #{file_name}"
    return
  end

  config = Config.new
  connection = Connection.new
  connection.post_json_request(
    config.gas_api_endpoint,
    create_request_object(file_name, has_caption_video_table.records)
  )
  puts "[END] upload to spreadsheet | #{file_name}"
end

def create_request_object(sheet_name, video_records)
  request = {}
  request['sheetName'] = sheet_name
  request['videos'] = video_records.map do |record|
    video = Video.new(record.video_id, record.title)
    video_hash = {}
    video_hash['title'] = video.title
    video_hash['url'] = video.url
    video_hash
  end
  JSON.generate(request)
end

config = Config.new
config.youtube_api_keys.each do |api_key|
  puts "use youtube api key #{api_key}"
  begin
    save_undetected_videos_process
    check_has_captions_process
  rescue StandardError => e
    puts e.class
    puts e.message
  end
  config.increment_api_key_index
end
upload_caption_video_to_spreadsheet_process
