class Tile
  attr_accessor :entity
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def occupied?
    !!@entity
  end
end
