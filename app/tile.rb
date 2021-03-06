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

    if under_mouse?
      graphics.setColor(colors.last)
      graphics.fill_rect x*tw+1, y*th+1, tw-3, th-3
    end

    colors.each_with_index do |color, index|
      graphics.setColor(color)

      margin = 3 + 2*index
      offset = 1 + index

      args = [
        x*tw+offset, # X position
        y*th+offset, # Y position
        tw-margin,   # width
        th-margin    # height
      ]

      graphics.draw_rect *args
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
    if sel_ent = $board.selected_entity
      sel_ent.in_range?(x, y, sel_ent.atk_range)
    end
  end

  def in_move_range?
    $board.selected_entity.try(:in_range?, x, y)
  end

  def colors
    colors = [Color.gray]

    if in_move_range? && $board.selected_entity.try(:can_move?)
      colors << Color.blue
    end

    if in_attack_range? && $board.selected_entity.try(:can_attack?)
      colors << Color.red
    end

    if selected?
      colors << Color.green
    end

    colors
  end
end
