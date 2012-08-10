require 'battle/dice'

class DamageDice < Dice
  def initialize(sides, modifier = 0)
    super(sides)
    self + modifier
  end

  def critical
    max / 20.0
  end
end
