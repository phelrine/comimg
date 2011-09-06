require 'net/http'
require 'cgi'

module UploadRequest
  CRLF = "\r\n"
  
  def self.mime_type(file)
    case
    when file =~ /\.jpg/ then 'image/jpg'
    when file =~ /\.gif$/ then 'image/gif'
    when file =~ /\.png$/ then 'image/png'
    else 'application/octet-stream'
    end
  end
  
  def self.request(uri, path)
    image = File.new path
    boundary = Time.now.to_i.to_s(16)
    boundary
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
    body = ""
    esc_key = CGI.escape("image")
    body << "--#{boundary}#{CRLF}"
    if image.respond_to?(:read)
      body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(image.path)}\"#{CRLF}"
      body << "Content-Type: #{self.mime_type(image.path)}#{CRLF}#{CRLF}"
      body << image.read
    else
      body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF}#{CRLF}#{image}"
    end
    body << CRLF
    body << "--#{boundary}--#{CRLF}#{CRLF}"
    request.body = body
    request["Content-Length"] = request.body.size
    request
  end
end
