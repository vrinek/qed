class Hud
  KEYS_HELP = {
    q: 'quit',
    r: 'reset',
    u: 'undo',
    enter: 'end turn'
  }

  def render(container, graphics)
    y = 8

    KEYS_HELP.each do |key, action|
      help_message = "<#{key.to_s.upcase}> to #{action}"

      graphics.draw_string(help_message, 828, y)

      y += 20
    end
  end
end
