require 'tile'

class Board
  attr_reader :name
  attr_reader :width, :height
  attr_reader :selected_tile, :tiles, :hovered_tile
  attr_reader :turn

  def initialize(map, viewport)
    @name = map.delete('name')

    @width = {
      :pixels => viewport.delete(:width),
      :tiles => map.delete('width').to_i
    }
    @height = {
      :pixels => viewport.delete(:height),
      :tiles => map.delete('height').to_i
    }

    warn_for_size

    @translation = viewport.delete(:translation)

    @tiles = Array.new(@width[:tiles]) do |x|
      Array.new(@height[:tiles]) do |y|
        Tile.new(x, y)
      end
    end

    @turn = 0
    @states = []
  end

  def initialize_entities(entities)
    entities.each do |entity|
      self << $creatures[entity["creature_id"]].dup.tap {|e|
        e.move entity["x"], entity["y"]
        e.set_current_hp(entity["hp"]) if entity["hp"]
        e.initialize_actions
      }
    end

    save_state!
  end

  def render(container, graphics)
    graphics.translate(@translation[:x], @translation[:y])

    th = Tile.height
    tw = Tile.width

    @tiles.flatten.each do |tile|
      tile.render(graphics)
    end

    graphics.translate(-@translation[:x], -@translation[:y])
  end

  def <<(entity)
    tile(entity.x, entity.y).entity = entity
  end

  def update(container, delta)
    input = container.get_input

    x = input.get_mouse_x - @translation[:x]
    y = input.get_mouse_y - @translation[:y]

    if @hovered_tile = tile_in(x, y)
      case
      when input.is_mouse_pressed(Input::MOUSE_LEFT_BUTTON)
        @hovered_tile.left_click
      when input.is_mouse_pressed(Input::MOUSE_RIGHT_BUTTON)
        @hovered_tile.right_click
      end
    end

    if input.is_key_pressed(Input::KEY_U)
      $board.undo_to_last_state
    end

    remove_dead_entities!
    update_entity_positions!
  end

  def selected_entity
    if @selected_tile.try(:entity).try(:player_controlled?)
      @selected_tile.entity
    end
  end

  def select_tile!(tile)
    @selected_tile = tile
  end

  def tile(x, y)
    row = @tiles[x]
    row[y] if row
  end

  def entities
    tiles.flatten.map(&:entity).compact
  end

  def start_enemy_turn
    monsters.each(&:reset_actions)

    monsters.each do |monster|
      monster.do_actions!
      update_entity_positions!
      remove_dead_entities!
    end
  end

  def end_player_turn
    @turn += 1

    start_enemy_turn

    characters.each(&:reset_actions)

    save_state!
  end

  def undo_to_last_state
    if last_state != current_state
      roll_back_to(last_state)
    elsif previous_state
      roll_back_to(previous_state)
      @turn -= 1
    end
  end

  def reset_to_first_state
    roll_back_to(@states[0])
    @turn = 0
  end

  private

  def roll_back_to(state)
    # Clear all entities
    @tiles.flatten.each {|tile| tile.entity = nil }

    # Re-add all entities
    $board.initialize_entities(state)
  end

  def previous_state
    return nil if @turn == 0

    @states[@turn - 1]
  end

  def last_state
    @states[@turn]
  end

  def save_state!
    if @states.size > @turn
      @states = @states[0..(@turn - 1)]
    end

    @states[@turn] = current_state
  end

  def current_state
    entities.map(&:current_state)
  end

  def characters
    entities.select(&:player_controlled?)
  end

  def monsters
    entities.reject(&:player_controlled?)
  end

  def update_entity_positions!
    @tiles.flatten.each do |tile|
      entity = tile.entity

      if entity && !entity.in?(tile.x, tile.y)
        tile.entity = nil
        self << entity
      end
    end
  end

  def remove_dead_entities!
    @tiles.flatten.select do |tile|
      tile.entity.respond_to?(:dead?) && tile.entity.dead?
    end.each do |tile|
      tile.entity = nil
    end
  end

  # return tile by absolute screen position
  def tile_in(x, y)
    tile_x = x/Tile.width
    tile_y = y/Tile.height

    return nil if tile_x < 0 || tile_y < 0

    tile(tile_x, tile_y)
  end

  def warn_for_size
    width_mod = @width[:pixels] % @width[:tiles]
    tile_width = @width[:pixels] / @width[:tiles]
    height_mod = @height[:pixels] % @height[:tiles]
    tile_height = @height[:pixels] / @height[:tiles]

    if width_mod != 0
      puts "Width in pixels is not a direct multiple of the width in tiles!"
      puts "#{@width[:pixels]} = #{@width[:tiles]} x #{tile_width} + #{width_mod}"
    end

    if height_mod != 0
      puts "Height in pixels is not a direct multiple of the height in tiles!"
      puts "#{@height[:pixels]} = #{@height[:tiles]} x #{tile_height} + #{height_mod}"
    end
  end
end
