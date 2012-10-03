class Hud
  KEYS_HELP = {
    q: 'quit',
    r: 'reset',
    u: 'undo',
    enter: 'end turn'
  }

  X_OFFSET = 800 + 20

  def render(container, graphics)
    render_turn(graphics)
    render_keys_help(graphics)
  end

  private

  def render_turn(graphics)
    turn = $board.turn
    x = X_OFFSET + 8

    graphics.draw_string("Turn: ##{turn}", x, 8)
  end

  def render_keys_help(graphics)
    y = 48
    x = X_OFFSET + 8

    KEYS_HELP.each do |key, action|
      help_message = "<#{key.to_s.upcase}> to #{action}"

      graphics.draw_string(help_message, x, y)

      y += 20
    end
  end
end
