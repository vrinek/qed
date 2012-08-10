require 'tile'

class Board
  attr_reader :width, :height, :selected_tile

  def initialize(options = {})
    @width = options.delete(:width) || 20
    @height = options.delete(:height) || 10

    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        Tile.new(x, y)
      end
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
    @tiles[entity.x][entity.y].entity = entity
  end

  def update(container, delta)
    input = container.get_input

    x = input.get_mouse_x
    y = input.get_mouse_y

    case
    when input.is_mouse_pressed(Input::MOUSE_LEFT_BUTTON)
      left_click_tile(x, y, container)
    when input.is_mouse_pressed(Input::MOUSE_RIGHT_BUTTON)
      right_click_tile(x, y, container)
    end

    update_entity_positions!
  end

  def occupied_tile?(x, y)
    @tiles[x][y].occupied?
  end

  def selected_entity
    @selected_tile && @selected_tile.entity
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
    @tiles.flatten.each do |tile|
      if tile.entity.respond_to?(:dead?) && tile.entity.dead?
        tile.entity = nil
      end
    end
  end

  def left_click_tile(x, y, container)
    clicked_tile = tile_in(x, y, container)

    if selected_entity
      # we had something selected, so we move it
      begin
        selected_entity.move(clicked_tile.x, clicked_tile.y)
        # keep the entity selected
      rescue Movable::OutOfRange
        # deselect the entity and select the clicked tile
      rescue Movable::OccupiedTile
        # deselect the current entity and select the clicked tile
      end
    end

    @selected_tile = clicked_tile
  end

  def right_click_tile(x, y, container)
    clicked_tile = tile_in(x, y, container)
    target_entity = clicked_tile.entity

    if selected_entity && target_entity
      begin
        selected_entity.attack!(target_entity)
      rescue Battleable::OutOfAttackRange
      rescue Battleable::SameEntity
      end
    end

    remove_dead_entities!
  end

  # return tile by absolute screen position
  def tile_in(x, y, container)
    tile_x = x/Tile.width(container)
    tile_y = y/Tile.height(container)

    @tiles[tile_x][tile_y]
  end
end
