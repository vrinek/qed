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
    end

    if can_attack? && target = next_attack
      attack!(target)
    end
  end
end
