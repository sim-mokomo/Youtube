require 'csv'

module MokomoGames
  class VideoSheet
    attr_reader :sheet_name, :records

    # @param [String] sheet_name
    def initialize(sheet_name)
      @sheet_name = sheet_name
      csv_file_path = File.expand_path("./outputs/#{sheet_name}.csv")
      @records = File.exist?(csv_file_path) ? load_from_file(csv_file_path) : []
    end

    # @param [String] csv_file_path
    # @return [Array<VideoSheetRecord>]
    def load_from_file(csv_file_path)
      f = CSV.open(csv_file_path)
      f.readline
      f.map { |row| VideoSheetRecord.new(
            row[0] || '',
            row[1] || '',
            row[2] || '',
            row[3].downcase == 'true' || false,
            row[4].downcase == 'true' || false)
          }
    end

    # @param record [VideoSheetRecord]
    def add_record(record)
      @records.push(record)
    end

    def exist_record(record)
      !@records.find { |x| x.video_id == record.video_id }.nil?
    end

    def write_to_file(enable_log = true)
      File.open("./outputs/#{@sheet_name}.csv", 'w') do |f|
        f.puts('video_id, title,url, is_japanese_caption, has_checked_caption')
        @records.each do |record|
          f.print("#{record.video_id},")
          f.print("#{record.title.gsub(/(,|")/, '')},")
          f.print("#{record.url},")
          f.print("#{record.is_japanese_caption},")
          f.print("#{record.has_checked_caption},")
          f.puts('')

          puts(":=> output video \t\t#{record.title} \t#{record.url}") if enable_log
        end
      end
    end
  end

  class VideoSheetRecord
    attr_reader :video_id, :title, :url
    attr_accessor :has_checked_caption, :is_japanese_caption

    def initialize(video_id, title, url, is_japanese_caption, has_checked_caption)
      @video_id = video_id
      @title = title
      @url = url
      @is_japanese_caption = is_japanese_caption
      @has_checked_caption = has_checked_caption
    end
  end
end
