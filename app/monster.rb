require 'movable'

class Monster
  include Movable

  attr_reader :image

  def initialize(options = {})
    @name = options.delete(:name)
    @image = Image.new(options.delete(:image_path))
  end
end
