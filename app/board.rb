class Board
  attr_reader :width, :height

  def initialize(options = {})
    @width = options.delete(:width) || 20
    @height = options.delete(:height) || 10

    @entities = Array.new(@width){Array.new(@height)}
  end

  def render(container, graphics)
    render_tiles(container, graphics)

    th = tile_height(container)
    tw = tile_width(container)

    @entities.flatten.compact.each do |entity|
      entity.image.draw entity.x*tw, entity.y*th, tw, th
    end
  end

  def <<(entity)
    @entities[entity.x][entity.y] = entity
  end

  def update(container, delta)
    input = container.get_input

    case
    when input.is_mouse_pressed(Input::MOUSE_LEFT_BUTTON)
      x = input.get_mouse_x
      y = input.get_mouse_y

      click_tile(x, y, container)
    end

    update_entity_positions!
  end

  private

  def update_entity_positions!
    @entities.each_with_index do |row, x|
      row.each_with_index do |entity, y|
        if entity && !entity.in?(x, y)
          @entities[x][y] = nil
          self << entity
        end
      end
    end
  end

  def click_tile(x, y, container)
    tile_x = x/tile_width(container)
    tile_y = y/tile_height(container)

    if selected_entity
      # we had something selected, so we move it
      begin
        selected_entity.move(tile_x, tile_y)

        # keep the entity selected
        @selected_tile = [tile_x, tile_y]
      rescue Movable::OutOfRange
        # deselect the entity
        @selected_tile = nil
      end
    else
      @selected_tile = [tile_x, tile_y]
    end
  end

  def selected_entity
    if @selected_tile
      x, y = @selected_tile
      @entities[x][y]
    else
      nil
    end
  end

  def render_tiles(container, graphics)
    prev_color = graphics.getColor

    th = tile_height(container)
    tw = tile_width(container)

    @height.times do |y|
      @width.times do |x|
        if @selected_tile == [x, y]
          graphics.setColor Color.green
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
