require 'movable'
require 'battle/battleable'

class Creature
  include Movable
  include Battleable

  attr_reader :image

  def initialize(options = {})
    @name = options.delete('name')
    @image = Image.new(options.delete('image_path'))

    options.each do |key, value|
      self.send(key + '=', value)
    end
  end

  def self.bulk_create(creatures)
    $creatures = creatures.inject(Hash.new) do |hash, creature|
      type = case creature.delete('type')
      when 'Monster'
        Monster
      when 'Character'
        Character
      end

      hash[creature.delete('id')] = type.new creature
      hash
    end
  end

  def render(tw, th)
    image.draw(x*tw, y*th, tw, th)
  end
end
