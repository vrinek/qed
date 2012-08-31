require 'tile'

class Board
  attr_reader :width, :height, :selected_tile, :tiles, :hovered_tile

  def initialize(map)
    @width = map.delete('width')
    @height = map.delete('height')

    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
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
    prev_color = graphics.getColor

    th = Tile.height(container)
    tw = Tile.width(container)

    @tiles.flatten.each do |tile|
      tile.render(container, graphics, tw, th)
    end

    graphics.setColor prev_color
  end

  def <<(entity)
    tile(entity.x, entity.y).entity = entity
  end

  def update(container, delta)
    input = container.get_input

    x = input.get_mouse_x
    y = input.get_mouse_y

    @hovered_tile = tile_in(x, y, container)

    case
    when input.is_mouse_pressed(Input::MOUSE_LEFT_BUTTON)
      @hovered_tile.left_click
    when input.is_mouse_pressed(Input::MOUSE_RIGHT_BUTTON)
      @hovered_tile.right_click
    end

    remove_dead_entities!
    update_entity_positions!
  end

  def selected_entity
    @selected_tile && @selected_tile.entity
  end

  def select_tile!(tile)
    @selected_tile = tile
  end

  def tile(x, y)
    @tiles[x][y]
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
  def tile_in(x, y, container)
    tile_x = x/Tile.width(container)
    tile_y = y/Tile.height(container)

    tile(tile_x, tile_y)
  end
end
