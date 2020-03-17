require_relative 'monster.rb'
require_relative 'heroes.rb'

class BattleState < State
  def initialize(window)
    super
    load_area(@window.get_area)
    load_monsters(@window.get_area)
    load_party

    @state = :initial_zoom_out
  end

  def load_party
    @party  = @window.get_party
    @heroes = []
    @party.each_with_index do |data, i|
      position = @party_spots[i]
      @heroes.push Hero.new(data, position)
    end
  end

  def load_area(area)
    @area = JSON.parse(File.read('data/areas.json'))[area]
    @to_draw = []
    @area['to_draw'].each {|e| @to_draw.push ObjModel.new(e)}
    
    @ennemy_spots = [
      Vector3.new(96, 0, 32),
      Vector3.new(64, 0, 64),
      Vector3.new(96, 0, 96)
    ]

    @party_spots = [
      Vector3.new(160, 0, 32),
      Vector3.new(192, 0, 64),
      Vector3.new(160, 0, 96)
    ]    
  end

  def load_monsters(area)
    @area_monsters = JSON.parse(File.read('data/monsters.json')).select {|k, v| @area['monsters'].include? k}
    @monsters = []
    (rand(3) + 1).times do |i| 
      type  = @area_monsters[@area_monsters.keys.sample]
      level = @area['level'] + rand(3) - 1
      @monsters.push Monster.new(type, @ennemy_spots[i], level)
    end
  end

  def update_camera
    case @state
    when :initial_zoom_out
      @camera_position ||= Vector3.new(128, 250, 200)
      @camera_target   ||= Vector3.new(128, 0, 16)
      @destination     ||= Vector3.new(128, 128, 300)
      done   = @camera_position.lerp_to(@destination, 0.045)
      @state = :main if done
    when :main
      p "test"
    end
  end

  def camera_look
    glEnable(GL_TEXTURE_2D)
    glEnable(GL_DEPTH_TEST)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(30, @window.width.to_f / @window.height, 1, 1000)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    gluLookAt(@camera_position.x, @camera_position.y, @camera_position. z,
      @camera_target.x, @camera_target.y, @camera_target.z,  0, 1, 0)
  end

  def draw_scene
    @to_draw.each {|e| e.draw}
  end

  def draw_monsters
    @monsters.each {|monster| monster.draw}
  end

  def draw_party
    @heroes.each {|hero| hero.draw}
  end

  def draw_menu

  end

  def update
    update_camera
  end
    
  def draw 
    Gosu::gl do
      camera_look
      draw_scene
      draw_monsters
      draw_party
      draw_menu
    end
  end
end
