require 'creature'
require 'battle/blind_attacker'

class Monster < Creature
  include BlindAttacker

  def player_controlled?
    false
  end

  def do_actions!
    if can_move? && tile = next_move
      move(tile.x, tile.y)
      @done << :move
    end

    if can_attack? && target = next_attack
      attack!(target)
      @done << :attack
    end
  end
end
