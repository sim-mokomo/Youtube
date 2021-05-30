require 'json'

class OutputConfig
  attr_reader :playlist_configs, :channel_configs

  def initialize
    File.open('./outputs_config/config.json') do |file|
      json_obj = JSON.parse(file.read)
      @playlist_configs = json_obj['playlist_configs'].map { |x| PlayListConfig.new(x['name'], x['id']) }
      @channel_configs = json_obj['channel_configs'].map { |x| ChannelConfig.new(x['name'], x['id'], x['enable']) }
    end
  end
end

class PlayListConfig
  attr_reader :name, :id

  def initialize(name, id)
    @name = name
    @id = id
  end
end

class ChannelConfig
  attr_reader :name, :id, :enable

  def initialize(name, id, enable)
    @name = name
    @id = id
    @enable = enable
  end
end
