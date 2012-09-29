lib_path = File.expand_path('../lib', __FILE__)
app_path = File.expand_path('../app', __FILE__)
$: << lib_path << app_path

# jruby
require 'java'

# java libraries
require 'lwjgl.jar'
require 'slick.jar'

# for JSON parsing
require 'gson.jar'
class Gson
  include_package "com.google.gson"

  def initialize
    @gson = GsonBuilder.new.
      setFieldNamingPolicy(FieldNamingPolicy::LOWER_CASE_WITH_UNDERSCORES).
      serializeNulls.create
  end

  def method_missing(method_name, *args)
    @gson.send(method_name, *args)
  end
end

java_import org.newdawn.slick.BasicGame
java_import org.newdawn.slick.GameContainer
java_import org.newdawn.slick.Graphics
java_import org.newdawn.slick.Input
java_import org.newdawn.slick.SlickException
java_import org.newdawn.slick.AppGameContainer
java_import org.newdawn.slick.Image
java_import org.newdawn.slick.Color

# application files
require './app/game'

# start up the game
app = AppGameContainer.new(Demo.new('SlickDemo'))
app.set_display_mode(1000, 520, false)
app.start
