require 'movable'
require 'battle/battleable'

class Creature
  include Movable
  include Battleable

  attr_reader :image

  def initialize(options = {})
    @name = options.delete(:name)
    @image = Image.new(options.delete(:image_path))
  end
end
