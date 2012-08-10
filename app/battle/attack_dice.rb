require 'battle/dice'

class AttackDice < Dice
  def initialize(modifier = 0)
    super(20)
    self + modifier
  end

  def with(dmg_dice)
    @dmg_dice = dmg_dice
    return self
  end

  def for(ac)
    @ac = ac
    return self
  end

  def total_dmg
    dmg = if @ac <= @modifier
      # special case where AC is too low
      hits 0
    elsif @ac >= @modifier + 20
      # special case where AC is too high
      0
    else
      # general case
      hits(@modifier - @ac)
    end + @dmg_dice.critical

    dmg.round
  end

  def hits(penalty)
    @dmg_dice.average / 20 * (19 + penalty)
  end
end
