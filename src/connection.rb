require 'net/https'
require 'uri'

class Connection
  def post_json_request(url, json)
    http, uri = create_https_connection(url)
    http.start do |h|
      request = Net::HTTP::Post.new(uri.path)
      request.body = json
      response = h.request(request)
      response = Net::HTTP.get_response(URI.parse(response.header['location'])) if response.code == '302'
      display_https_response(response)
    end
  end

  def create_https_connection(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    [http, uri]
  end

  def display_https_response(response)
    p response.code
    p JSON.parse(response.body)
  end
end
