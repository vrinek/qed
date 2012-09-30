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
    if $board.selected_entity.try(:can_move?)
      # we had something selected, so we move it
      begin
        $board.selected_entity.move(self.x, self.y)
        $board.selected_entity.consume_action :move
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
    if $board.selected_entity.try(:can_attack?) && entity
      begin
        $board.selected_entity.attack!(entity)
        $board.selected_entity.consume_action :attack
      rescue Battleable::OutOfAttackRange
      rescue Battleable::SameEntity
      end
    end
  end

  def render(graphics)
    th = Tile.height
    tw = Tile.width

    graphics.setColor(color)
    graphics.draw_rect x*tw+1, y*th+1, tw-3, th-3

    if under_mouse?
      graphics.fill_rect x*tw+1, y*th+1, tw-3, th-3
    end

    if entity
      entity.render(tw, th)

      if entity.respond_to?(:hp) && under_mouse?
        entity.render_hp_bar(graphics, tw, th)
      end
    end
  end

  def self.width
    $board.width[:pixels] / $board.width[:tiles]
  end

  def self.height
    $board.height[:pixels] / $board.height[:tiles]
  end

  private

  def under_mouse?
    $board.hovered_tile == self
  end

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
    when in_attack_range? && $board.selected_entity.try(:can_attack?)
      Color.red
    when in_move_range? && $board.selected_entity.try(:can_move?)
      Color.blue
    else
      Color.gray
    end
  end
end
