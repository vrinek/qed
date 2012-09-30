require 'movable'
require 'battle/battleable'

class Creature
  include Movable
  include Battleable

  attr_reader :image
  attr_reader :can_do, :done

  def initialize(options = {})
    @name = options.delete('name')
    @image = Image.new(options.delete('image_path'))

    @can_do = []
    @done = []

    # Calls the parents' `initialize` method (includes Movable and Battleable).
    #
    # @note `super` passes all arguments to the parent's method.  `super()`
    #   passes no arguments to the parent.
    super()

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

  # To be replaced by AI
  def target
    nil
  end

  def method_missing(method_name, *args, &block)
    if method_name =~ /^can_/
      action = method_name[/can_(.+)\?$/, 1].to_sym

      @can_do.include?(action) && !@done.include?(action)
    else
      super
    end
  end
end
