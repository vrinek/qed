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
    $board = Board.new width: 20, height: 10

    goblin = Monster.new(name: 'goblin', image_path: 'assets/goblin.png')
    goblin.range = 4
    goblin.atk_mod = 6
    goblin.atk_range = 3
    goblin.dmg_dice = 6
    goblin.dmg_mod = 5
    goblin.ac = 15
    goblin.hp = 30

    $board << goblin.dup.tap{|g| g.move(3,2)}
    $board << goblin.dup.tap{|g| g.move(1,4)}
    $board << goblin.dup.tap{|g| g.move(1,7)}

    warrior = Character.new name: 'warrior', image_path: 'assets/warrior.png'
    warrior.range = 3
    warrior.atk_mod = 4
    warrior.atk_range = 1
    warrior.dmg_dice = 10
    warrior.dmg_mod = 2
    warrior.ac = 15
    warrior.hp = 24

    $board << warrior.dup.tap{|w| w.move(18,5)}
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
    end

    $board.update(container, delta)
  end
end

app = AppGameContainer.new(Demo.new('SlickDemo'))
app.set_display_mode(800, 400, false)
app.start
