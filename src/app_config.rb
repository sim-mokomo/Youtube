require 'json'
require './src/extensions/object_extensions'

class AppConfig
  attr_reader :gas_api_endpoint, :youtube_api_keys

  def initialize
    File.open('app_config.json') do |file|
      json = JSON.parse(file.read)
      @youtube_api_keys = json['youtube_api_keys']
      @gas_api_endpoint = json['gas_api_endpoint']
      @use_youtube_api_key_index = json['use_youtube_api_key_index'].to_i
    end
  end

  def current_api_key
    @youtube_api_keys[@use_youtube_api_key_index]
  end

  def increment_api_key_index
    @use_youtube_api_key_index += 1
    @use_youtube_api_key_index = @use_youtube_api_key_index % @youtube_api_keys.length
    save
  end

  def reset_api_key_idnex
    @use_youtube_api_key_index = 0
    save
  end

  def save
    File.open('app_config.json', File::WRONLY | File::SYNC | File::TRUNC | File::CREAT) do |file|
      file.puts(JSON.pretty_generate(to_hash_object))
    end
  end
end
