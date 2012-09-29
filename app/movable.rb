module Movable
  attr_reader :x, :y
  attr_accessor :range

  def move(x, y)
    if x < 0 || y < 0 || x > $board.width[:tiles]-1 || y > $board.height[:tiles]-1
      raise OutOfBoard
    end

    if $board.tile(x, y).occupied?
      raise OccupiedTile
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

  def in_range?(x, y, range = nil)
    distance(x, y) <= (range || self.range)
  end

  # Square distance
  def distance(x, y)
    dx = (x - self.x).abs
    dy = (y - self.y).abs

    # Octagonal distance
    (dx - dy).abs + 1.5 * [dx,dy].min
  end

  def closest(klass)
    $board.entities.
      select{|entity| entity.is_a?(klass)}.
      sort_by{|entity| distance(entity.x, entity.y) }.
      first
  end

  class OutOfBoard < Exception; end
  class OutOfRange < Exception; end
  class OccupiedTile < Exception; end
end
