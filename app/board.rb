require 'tile'

class Board
  attr_reader :name
  attr_reader :width, :height
  attr_reader :selected_tile, :tiles, :hovered_tile

  def initialize(map, viewport)
    @name = map.delete('name')

    @width = {
      :pixels => viewport.delete(:width),
      :tiles => map.delete('width')
    }
    @height = {
      :pixels => viewport.delete(:height),
      :tiles => map.delete('height')
    }

    @translation = viewport.delete(:translation)

    @tiles = Array.new(@width[:tiles]) do |x|
      Array.new(@height[:tiles]) do |y|
        Tile.new(x, y)
      end
    end
  end

  def initialize_entities(entities)
    entities.each do |entity|
      self << $creatures[entity["creature_id"]].dup.tap {|e|
        e.move entity["x"], entity["y"]
      }
    end
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

  def end_turn
    entities.reject(&:player_controlled?).each do |enemy|
      if enemy.can_move? && tile = enemy.next_move
        enemy.move(tile.x, tile.y)
        update_entity_positions!
      elsif enemy.can_attack? && target = enemy.next_attack
        enemy.attack!(target)
      end
    end
  end

  private

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
end
