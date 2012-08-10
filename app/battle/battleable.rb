require 'battle/attack_dice'
require 'battle/damage_dice'

module Battleable
  attr_accessor :atk_mod, :dmg_dice, :dmg_mod, :ac, :hp

  def attack!(entity)
    raise NotAttackable unless entity.respond_to?(:hp)

    entity.take_dmg!(dmg_to(entity))
  end

  def dmg_to(entity)
    AttackDice.new(@atk_mod).
      with(DamageDice.new(dmg_dice, dmg_mod)).
      for(entity.ac).
      total_dmg
  end

  def take_dmg!(dmg)
    @hp -= dmg

    puts "#{@name} HP: #{@hp}"
  end

  def dead?
    hp <= 0
  end

  class NotAttackable < Exception; end
end
