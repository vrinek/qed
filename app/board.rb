class Board
  attr_reader :width, :height

  def initialize(options = {})
    @width = options.delete(:width) || 20
    @height = options.delete(:height) || 10

    @entities = []
  end

  def render(container, graphics)
    render_tiles(container, graphics)

    th = tile_height(container)
    tw = tile_width(container)

    @entities.each do |entity|
      entity.image.draw entity.x*tw, entity.y*th, tw, th
    end
  end

  def add_entity(entity)
    @entities << entity
  end

  private

  def render_tiles(container, graphics)
    th = tile_height(container)
    tw = tile_width(container)

    @height.times do |y|
      @width.times do |x|
        graphics.draw_rect x*tw, y*th, tw, th
      end
    end
  end

  def tile_width(container)
    container.width / @width
  end

  def tile_height(container)
    container.height / @height
  end
end
