require 'battle/attack_dice'
require 'battle/damage_dice'

module Battleable
  attr_accessor :atk_mod, :atk_range
  attr_accessor :dmg_dice, :dmg_mod
  attr_accessor :ac, :hp

  attr_reader :total_hp

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
  end

  def dead?
    hp <= 0
  end

  def total_hp=(amount)
    @total_hp = amount
    @hp = amount
  end

  def hp_portion
    @hp/@total_hp.to_f
  end

  def render_hp_bar(graphics, tw, th)
    # red part
    graphics.set_color Color.red
    graphics.fill_rect(x*tw+2, y*th-4, tw-4, 4)

    # green part
    graphics.set_color Color.green
    graphics.fill_rect(x*tw+2, y*th-4, (tw-4)*hp_portion, 4)

    # border
    graphics.set_color Color.white
    graphics.draw_rect(x*tw+2, y*th-4, tw-4, 4)
  end

  class OutOfAttackRange < Exception; end
  class NotAttackable < Exception; end
  class SameEntity < Exception; end
end
