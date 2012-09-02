require 'board'
require 'monster'
require 'character'

class Demo < BasicGame
  # Due to how Java decides which method to call based on its
  # method prototype, it's good practice to fill out all necessary
  # methods even with empty definitions.
  def init(container)
    map = load_map('test_map01.json')

    viewport = {
      width: 800, height: 480,
      translation: {x: 20, y: 20}
    }

    # initialize the map
    $board = Board.new map, viewport

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

  private

  def load_map(filename)
    json = File.open(File.join('maps', filename)).read

    Gson.new.from_json json, Hash.new.to_java.java_class
  end
end
