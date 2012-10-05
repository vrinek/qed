require 'board'
require 'monster'
require 'character'
require 'hud'

class Demo < BasicGame
  # Starts the game.  This method is called by the AppGameContainer.
  #
  # @param container [AppGameContainer] the game's container
  def init(container)
    map = load_map('test_map01.json')

    # This is the map's viewport.  The rest of the screen is for the HUD and
    #   margins.
    viewport = {
      :width => 800, :height => 480,
      :translation => {:x => 20, :y => 20}
    }

    # Initializes the map inside the viewport.
    $board = Board.new map, viewport

    # Instantiates the creature prototypes.
    Creature.bulk_create(map['creatures'])

    # Instantiates the creatures and moves them into position.
    $board.initialize_entities(map['entities'])

    # Initializes the HUD.
    $hud = Hud.new
  end

  # Renders one frame of the game.  This method is being called constantly.
  #
  # @param container [AppGameContainer] the game's container
  # @param graphics [Graphics] an object to handle all graphics drawing
  def render(container, graphics)
    $board.render(container, graphics)
    $hud.render(container, graphics)
  end

  # Updates the state of the game given some player input.  This method is being
  #   called constantly.
  #
  # @param container [AppGameContainer] the game's container
  # @param delta [Float] the time difference in seconds from the last update
  def update(container, delta)
    # Grab input and exit if escape is pressed
    input = container.get_input

    case
    when input.is_key_down(Input::KEY_Q)
      container.exit
    when input.is_key_pressed(Input::KEY_R)
      $board.reset_to_first_state
    when input.is_key_pressed(Input::KEY_ENTER)
      $board.end_player_turn
    end

    $board.update(container, delta)
  end

  private

  # Loads a map from the filesystem.
  def load_map(filename)
    json = File.open(File.join('maps', filename)).read

    Gson.new.from_json json, Hash.new.to_java.java_class
  end
end
