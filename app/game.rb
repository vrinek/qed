lib_path = File.expand_path('../../lib', __FILE__)
app_path = File.expand_path('../../app', __FILE__)
$: << lib_path << app_path

# jruby
require 'java'

# java libraries
require 'lwjgl.jar'
require 'slick.jar'

# ruby standard libraries
require 'json'

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
    map = JSON.parse(File.open('maps/test_map01.json').read)

    # initialize the map
    $board = Board.new map

    # create the creatures (as prototypes)
    Creature.bulk_create(map['creatures'])

    # instantiate the creatures and move them into position
    $board.initialize_entities(map['entities'])
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
    when input.is_key_pressed(Input::KEY_R)
      container.reinit
    end

    $board.update(container, delta)
  end
end

app = AppGameContainer.new(Demo.new('SlickDemo'))
app.set_display_mode(800, 400, false)
app.start
