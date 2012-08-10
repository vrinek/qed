require 'tile'

class Board
  attr_reader :width, :height

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
    render_tiles(container, graphics)

    th = tile_height(container)
    tw = tile_width(container)

    @tiles.flatten.map(&:entity).compact.each do |entity|
      entity.image.draw entity.x*tw, entity.y*th, tw, th
    end
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
    tile_x = x/tile_width(container)
    tile_y = y/tile_height(container)

    if selected_entity
      # we had something selected, so we move it
      begin
        selected_entity.move(tile_x, tile_y)
        # keep the entity selected
      rescue Movable::OutOfRange
        # deselect the entity and select the clicked tile
      rescue Movable::OccupiedTile
        # deselect the current entity and select the clicked tile
      end
    end

    @selected_tile = @tiles[tile_x][tile_y]
  end

  def right_click_tile(x, y, container)
    tile_x = x/tile_width(container)
    tile_y = y/tile_height(container)
    target_entity = @tiles[tile_x][tile_y].entity

    if selected_entity && target_entity
      begin
        selected_entity.attack!(target_entity)
      rescue Battleable::OutOfAttackRange
      rescue Battleable::SameEntity
      end
    end

    remove_dead_entities!
  end

  def selected_entity
    @selected_tile && @selected_tile.entity
  end

  def render_tiles(container, graphics)
    prev_color = graphics.getColor

    th = tile_height(container)
    tw = tile_width(container)

    @height.times do |y|
      @width.times do |x|
        if @selected_tile == @tiles[x][y]
          graphics.setColor Color.green
        elsif selected_entity &&
          selected_entity.in_range?(x, y, selected_entity.atk_range)

          graphics.setColor Color.red
        elsif selected_entity && selected_entity.in_range?(x, y)
          graphics.setColor Color.blue
        else
          graphics.setColor Color.gray
        end

        graphics.draw_rect x*tw, y*th, tw-2, th-2
      end
    end

    graphics.setColor prev_color
  end

  def tile_width(container)
    container.width / @width
  end

  def tile_height(container)
    container.height / @height
  end
end
