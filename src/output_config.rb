require 'json'

class OutputConfig
  attr_reader :playlist_configs

  def initialize
    File.open('./output_config.json') do |file|
      json_obj = JSON.parse(file.read)
      @playlist_configs = json_obj['playlist_configs'].map { |x| PlayListConfig.new(x['name'], x['id']) }
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
