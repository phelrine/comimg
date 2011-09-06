require 'userstream'
require 'twitter-text'

$:.unshift File.dirname(__FILE__)
require 'upload_request'
require 'command'

class Comimg
  @@uri = URI.parse "http://api.twitter.com/1/account/update_profile_image.json"
  
  def initialize(consumer_key, consumer_secret, access_token, access_secret)
    @consumer = OAuth::Consumer.new(consumer_key, consumer_secret,
      site: 'https://userstream.twitter.com'
      )
    @api = OAuth::Consumer.new(consumer_key, consumer_secret,
      site: 'http://api.twitter.com'
      )
    
    @access_token = OAuth::AccessToken.new @consumer, access_token, access_secret
  end

  def run
    Userstream.new(@consumer, @access_token).user{|status|
      puts status.text
      users = Twitter::Extractor.extract_mentioned_screen_names status.text
      puts users
      if users.include? "phelrine"
        command = Command.new status.text
        command.execute
        upload
      end
    }
  end

  def upload
    Net::HTTP.new(@@uri.host, @@uri.port).start{|http|
      request = UploadRequest.request @@uri, "current_image.png"
      request.body
      @api.sign! request, @access_token
      http.request request
    }
  end
end

CONSUMER_KEY, CONSUMER_SECRET, ACCESS_TOKEN, ACCESS_SECRET = 
  File.new(".config").read.split

coming = Comimg.new CONSUMER_KEY, CONSUMER_SECRET, ACCESS_TOKEN, ACCESS_SECRET
coming.run
