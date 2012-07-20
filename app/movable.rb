module Movable
  attr_reader :x, :y

  def move(x, y)
    if x < 0 || y < 0 || x > $board.width-1 || y > $board.height-1
      raise OutOfBoard
    end

    @x, @y = x, y
  end

  class OutOfBoard < Exception; end
end
