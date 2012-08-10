class Dice
  def initialize(sides)
    @sides = sides
    @modifier = 0
  end

  def +(modifier)
    @modifier += modifier
    return self
  end

  def max
    @sides + @modifier
  end

  def average
    @sides/2 + 0.5 + @modifier
  end
end
