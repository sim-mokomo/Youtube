require './youtube_service'
require './video_sheet'

def output_videos(file_name, videos)
  sheet = VideoSheet.new(file_name)
  records = videos.map { |x| VideoSheetRecord.new(x.video_id, x.title, x.url) }
  records.each do |record|
    sheet.add_record(record) unless sheet.exist_record(record)
  end

  sheet.write_to_file
end

def check_japanese_caption(sheet_name)
  sheet = VideoSheet.new(sheet_name)
  sheet.records.each do |record|
    next if record.has_checked_caption

    contain = Video.new(record.video_id, '').contain_language_caption('ja')
    record.is_japanese_caption = true if contain
    puts(":=> check japanese caption #{contain ? 'success' : 'not found'}")
    record.has_checked_caption = true
    sheet.write_to_file(false)
  end
end

output_videos('JemesRecommend_ALL', PlayList.new('PLhyKYa0YJ_5DNVpOci8qhGuI4mFYcIm4V'))
output_videos('ExtraMythology_ALL', PlayList.new('PLhyKYa0YJ_5BPIbL5ROX4RUByP5IjuGkr'))
output_videos('ExtraPolitics_ALL', PlayList.new('PLhyKYa0YJ_5BMjoxHASNb0uGK_XQrUx9D'))
output_videos('ExtraSciFi_ALL', PlayList.new('PLhyKYa0YJ_5AuEhpcGAo4ngmSDKuFgZZx'))
output_videos('DesignClab_ALL', PlayList.new('PLhyKYa0YJ_5CH8BA8XcqReieXLFf4afI0'))
output_videos('ExtraRemix_ALL', PlayList.new('PLhyKYa0YJ_5DXcFVYYJLcNuNQ0ISa7rPQ'))
output_videos('ExtraCredit_ALL', PlayList.new('PLB9B0CA00461BB187'))
output_videos('ExtraHistory_ALL', PlayList.new('PLhyKYa0YJ_5Aq7g4bil7bnGi0A8gTsawu'))
output_videos('GameMakerToolKit_ALL', PlayList.new('PLc38fcMFcV_s7Lf6xbeRfWYRt7-Vmi_X9'))
output_videos('Expresso_Coffee_Baby_Back_Kahlua_Ribs_Recipe_BBQ_Pit_Boys', PlayList.new('PL93F0C1697BFA8A14'))

check_japanese_caption('JemesRecommend_ALL')
check_japanese_caption('The_Coding_Train_ALL')
check_japanese_caption('GameMakerToolKit_ALL')
check_japanese_caption('ExtraHistory_ALL')
check_japanese_caption('ExtraCredit_ALL')
check_japanese_caption('Expresso_Coffee_Baby_Back_Kahlua_Ribs_Recipe_BBQ_Pit_Boys')
