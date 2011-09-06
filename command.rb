require 'RMagick'

class Command
  def initialize(status)
    _, @command, @param = status.split
  end
  
  def execute
    sign = @command == "right"? 1 : -1
    img = Magick::Image.read("current_image.png").first
    param = @param.to_i * sign
    img = img.roll(param, 0)
    img.write "current_image.png"
  end
end
