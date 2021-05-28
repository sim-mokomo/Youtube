require './youtube_service_wrapper'
require './video_sheet'

def fetch_video_infos_from_channel(options)
  channel_id = options[:channel_id]
  youtube_service = MokomoGames::YoutubeServiceWrapper.new
  video_infos = []
  response = nil
  loop do
    response = if response.nil?
                youtube_service.get_channel_videos_from_search(channel_id, nil)
               else
                youtube_service.get_channel_videos_from_search(channel_id, response.next_page_token)
               end

    video_infos = video_infos.concat(response.items.map { |x|
      {
        video_id: x.id.video_id,
        title: x.snippet.title
      }
    })

    break if response.next_page_token.nil?
  end

  video_infos
end

def fetch_video_infos_from_playlist(options)
  playlist_id = options[:playlist_id]
  youtube_service = MokomoGames::YoutubeServiceWrapper.new
  video_infos = []
  playlist_item_response = nil
  loop do
    playlist_item_response = if playlist_item_response.nil?
                               youtube_service.get_videos_from_playlist(
                                 playlist_id,
                                 nil
                               )
                             else
                               youtube_service.get_videos_from_playlist(
                                 playlist_id,
                                 playlist_item_response.next_page_token
                               )
                             end

    video_infos = video_infos.concat(playlist_item_response.items.map { |x|
      {
        video_id: x.snippet.resource_id.video_id,
        title: x.snippet.title
      }
    })

    break if playlist_item_response.next_page_token.nil?
  end

  video_infos
end

def output_videos(file_name, search_videos_func, search_videos_options)
  sheet = MokomoGames::VideoSheet.new(file_name)

  video_infos = search_videos_func.call(search_videos_options)

  records = video_infos.map { |x|
    MokomoGames::VideoSheetRecord.new(
      x[:video_id],
      x[:title],
      MokomoGames::YoutubeServiceWrapper.create_youtube_url(x[:video_id]),
      false,
      false
    )
  }

  records.each do |record|
    sheet.add_record(record) unless sheet.exist_record(record)
  end

  sheet.write_to_file
end

def check_japanese_caption(sheet_name)
  youtube_service = MokomoGames::YoutubeServiceWrapper.new
  sheet = MokomoGames::VideoSheet.new(sheet_name)
  sheet.records.each do |record|
    next if record.has_checked_caption

    print(":=> check japanese caption ")
    contain = youtube_service.contain_language_caption('ja', record.video_id)
    if contain
      record.is_japanese_caption = true
    end
    puts(contain ? "success" : "not found")
    record.has_checked_caption = true
    sheet.write_to_file(false)
  end
end

# NOTE: プレイリストから出力
fetch_video_infos_from_playlist_func_obj = method(:fetch_video_infos_from_playlist)
# output_videos('JemesRecommend_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLhyKYa0YJ_5DNVpOci8qhGuI4mFYcIm4V'})
# output_videos('ExtraMythology_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLhyKYa0YJ_5BPIbL5ROX4RUByP5IjuGkr'})
# output_videos('ExtraPolitics_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLhyKYa0YJ_5BMjoxHASNb0uGK_XQrUx9D'})
# output_videos('ExtraSciFi_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLhyKYa0YJ_5AuEhpcGAo4ngmSDKuFgZZx'})
# output_videos('DesignClab_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLhyKYa0YJ_5CH8BA8XcqReieXLFf4afI0'})
# output_videos('ExtraRemix_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLhyKYa0YJ_5DXcFVYYJLcNuNQ0ISa7rPQ'})
# output_videos('ExtraCredit_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLB9B0CA00461BB187'})
# output_videos('ExtraHistory_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLhyKYa0YJ_5Aq7g4bil7bnGi0A8gTsawu'})
# output_videos('GameMakerToolKit_ALL', fetch_video_infos_from_playlist_func_obj,{playlist_id: 'PLc38fcMFcV_s7Lf6xbeRfWYRt7-Vmi_X9'})
# output_videos(
#   'Expresso_Coffee_Baby_Back_Kahlua_Ribs_Recipe_BBQ_Pit_Boys',
#   fetch_video_infos_from_playlist_func_obj,
#   {playlist_id: 'PL93F0C1697BFA8A14'})

# NOTE: チャンネルから出力
fetch_video_infos_from_channel_func_obj = method(:fetch_video_infos_from_channel)
# output_videos('The_Coding_Train_ALL', fetch_video_infos_from_channel_func_obj,{channel_id: 'UCvjgXvBlbQiydffZU7m1_aw'})

# NOTE: 字幕チェック
# check_japanese_caption('JemesRecommend_ALL')
# check_japanese_caption('The_Coding_Train_ALL')
# check_japanese_caption('GameMakerToolKit_ALL')
# check_japanese_caption('ExtraHistory_ALL')
# check_japanese_caption('ExtraCredit_ALL')
check_japanese_caption('Expresso_Coffee_Baby_Back_Kahlua_Ribs_Recipe_BBQ_Pit_Boys')