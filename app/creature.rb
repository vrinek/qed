require 'movable'
require 'battle/battleable'

class Creature
  include Movable
  include Battleable

  attr_reader :image

  def initialize(options = {})
    @name = options.delete('name')
    @image = Image.new(options.delete('image_path'))
    @type_id = options.delete('id')

    options.each do |key, value|
      self.send(key + '=', value)
    end
  end

  # `initialize` is called to instanciate the "blueprints" for the Creatures.
  # To avoid having all instances of a blueprint point to the same arrays for
  #   `@done` and `@can_do` we need to initialize them after they get
  #   dupplicated from the blueprints.
  def initialize_actions
    @can_do = []
    @done = []

    self.class.included_modules.each do |mod|
      if mod.respond_to?(:can_do)
        @can_do += mod.can_do
      end
    end
  end

  def reset_actions
    @done = []
  end

  def self.bulk_create(creatures)
    $creatures = creatures.inject(Hash.new) do |hash, creature|
      type = case creature.delete('type')
      when 'Monster'
        Monster
      when 'Character'
        Character
      end

      hash[creature['id']] = type.new creature
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

  def consume_action(action)
    @done << action
  end

  def method_missing(method_name, *args, &block)
    if is_about_action?(method_name)
      action = method_name[/^can_(.+)\?$/, 1].to_sym

      @can_do.include?(action) && !@done.include?(action)
    else
      super
    end
  end

  # We need to redefine `respond_to?` in order for `try` to work properly.
  def respond_to?(method_name, *args)
    is_about_action?(method_name) || super
  end

  def current_state
    state = {
      'creature_id' => @type_id
    }

    self.class.included_modules.each do |mod|
      if mod.respond_to?(:current_state)
        state = state.merge(mod.current_state(self))
      end
    end

    state
  end

  private

  def is_about_action?(method_name)
    method_name =~ /^can_/
  end
end
