class Tile
  attr_accessor :entity
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def occupied?
    !!@entity
  end

  def left_click
    if $board.selected_entity
      # we had something selected, so we move it
      begin
        $board.selected_entity.move(self.x, self.y)
        # keep the entity selected
      rescue Movable::OutOfRange
        # deselect the entity and select the clicked tile
      rescue Movable::OccupiedTile
        # deselect the current entity and select the clicked tile
      end
    end

    $board.select_tile! self
  end

  def right_click
    if $board.selected_entity && entity
      begin
        $board.selected_entity.attack!(entity)
      rescue Battleable::OutOfAttackRange
      rescue Battleable::SameEntity
      end
    end
  end

  def render(container, graphics, tw, th)
    graphics.setColor(color)
    graphics.draw_rect x*tw, y*th, tw-2, th-2

    entity.image.draw(entity.x*tw, entity.y*th, tw, th) if entity
  end

  def self.width(container)
    container.width / $board.width
  end

  def self.height(container)
    container.height / $board.height
  end

  private

  def selected?
    $board.selected_tile == self
  end

  def in_attack_range?
    sel_entity = $board.selected_entity
    sel_entity && sel_entity.in_range?(x, y, sel_entity.atk_range)
  end

  def in_move_range?
    sel_entity = $board.selected_entity
    sel_entity && sel_entity.in_range?(x, y)
  end

  def color
    case
    when selected?
      Color.green
    when in_attack_range?
      Color.red
    when in_move_range?
      Color.blue
    else
      Color.gray
    end
  end
end
