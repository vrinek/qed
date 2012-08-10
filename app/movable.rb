module Movable
  attr_reader :x, :y
  attr_accessor :range

  def move(x, y)
    if x < 0 || y < 0 || x > $board.width-1 || y > $board.height-1
      raise OutOfBoard
    end

    # @x and @y are nil when the Movable object has first been initialized
    if @x && @y && !in_range?(x, y)
      raise OutOfRange
    end

    @x, @y = x, y
  end

  def in?(x, y)
    @x == x && @y == y
  end

  def in_range?(x, y)
    distance(x, y) <= range
  end

  # Square distance
  def distance(x, y)
    [(x - @x).abs, (y - @y).abs].max
  end

  class OutOfBoard < Exception; end
  class OutOfRange < Exception; end
end
