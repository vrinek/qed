lib_path = File.expand_path('../../lib', __FILE__)
app_path = File.expand_path('../../app', __FILE__)
$: << lib_path << app_path

# jruby
require 'java'

# libraries
require 'lwjgl.jar'
require 'slick.jar'

java_import org.newdawn.slick.BasicGame
java_import org.newdawn.slick.GameContainer
java_import org.newdawn.slick.Graphics
java_import org.newdawn.slick.Input
java_import org.newdawn.slick.SlickException
java_import org.newdawn.slick.AppGameContainer
java_import org.newdawn.slick.Image
java_import org.newdawn.slick.Color

# application files
require 'board'
require 'monster'
require 'character'

class Demo < BasicGame
  # Due to how Java decides which method to call based on its
  # method prototype, it's good practice to fill out all necessary
  # methods even with empty definitions.
  def init(container)
    $board = Board.new

    goblin = Monster.new(name: 'goblin', image_path: 'assets/goblin.png')

    $board.add_entity goblin.dup.tap{|g| g.move(3,9)}
    $board.add_entity goblin.dup.tap{|g| g.move(1,4)}
    $board.add_entity goblin.dup.tap{|g| g.move(1,7)}

    warrior = Character.new name: 'warrior', image_path: 'assets/warrior.png'

    $board.add_entity warrior.dup.tap{|w| w.move(18,5)}
  end

  def render(container, graphics)
    $board.render(container, graphics)

    graphics.draw_string('JRuby Demo (Q to quit)', 8, container.height - 30)
  end

  def update(container, delta)
    # Grab input and exit if escape is pressed
    input = container.get_input

    case
    when input.is_key_down(Input::KEY_Q)
      container.exit
    when input.is_mouse_pressed(Input::MOUSE_LEFT_BUTTON)
      x = input.get_mouse_x
      y = input.get_mouse_y

      $board.select_tile(x, y, container)
    end
  end
end

app = AppGameContainer.new(Demo.new('SlickDemo'))
app.set_display_mode(800, 400, false)
app.start
