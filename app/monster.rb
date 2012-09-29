require 'creature'
require 'battle/blind_attacker'

class Monster < Creature
  include BlindAttacker

  def player_controlled?
    false
  end
end
