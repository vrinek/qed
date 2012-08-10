require 'battle/attack_dice'
require 'battle/damage_dice'

module Battleable
  attr_accessor :atk_mod, :atk_range
  attr_accessor :dmg_dice, :dmg_mod
  attr_accessor :ac, :hp

  def attack!(entity)
    if !entity.respond_to?(:hp)
      raise NotAttackable
    end

    if !in_range?(entity.x, entity.y, @atk_range)
      raise OutOfAttackRange
    end

    if entity == self
      raise SameEntity
    end

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

  class OutOfAttackRange < Exception; end
  class NotAttackable < Exception; end
  class SameEntity < Exception; end
end
