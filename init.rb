require 'json'
require 'gosu'
require 'opengl'
require 'glu'

OpenGL.load_lib
GLU.load_lib

include OpenGL, GLU

require_relative 'lib/utils.rb'
require_relative 'lib/obj_model.rb'
require_relative 'lib/state.rb'
require_relative 'lib/battle_state.rb'

class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    @font = Gosu::Font.new(24)
    load_party
    @main_state = BattleState.new(self)
  end

  def needs_cursor?; true; end

  def button_down(id)
    super
    @main_state.button_down(id)
    close! if id == Gosu::KB_ESCAPE
  end

  def button_up(id)
    @main_state.button_up(id)
  end

  def load_party
    heroes = JSON.parse(File.read('data/heroes.json'))
    @party = [
      heroes['alex'],
      heroes['mary'],
      heroes['alex']
    ]
  end

  def get_area
    'city'
  end

  def get_party
    @party
  end

  def update
    @main_state.update
  end

  def draw
    @main_state.draw
  end
end

Window.new.show
