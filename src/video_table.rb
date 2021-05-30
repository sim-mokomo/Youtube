require 'csv'

class VideoTable
  attr_reader :records

  # @param [String] file_name
  def initialize(base_dir, file_name)
    @base_dir = base_dir
    @file_name = file_name
    @records = []
    @records = load
  end

  def file_path
    File.expand_path("#{@base_dir}/#{@file_name}.json")
  end

  # @return [Array<VideoRecord>]
  def load
    return [] unless File.exist?(file_path)

    @records.clear
    File.open(file_path) do |file|
      objs = JSON.parse(file.read)
      return [] if objs.length.zero?

      return objs.map { |x| VideoRecord.new(x['video_id'], x['title']) }
    end
  end

  # @param record [VideoRecord]
  def add_record(record)
    @records.push(record)
  end

  def exist_record(record)
    !@records.find { |x| x.video_id == record.video_id }.nil?
  end

  def overwrite_save(records)
    @records = records
    save
  end

  def save
    hashes = @records.map(&:to_hash_object)
    File.open(file_path, 'w') do |f|
      f.puts(JSON.pretty_generate(hashes))
    end
  end

  def empty
    @records.length.zero?
  end
end

class VideoRecord
  attr_reader :video_id, :title

  def initialize(video_id, title)
    @video_id = video_id
    @title = title
  end
end
