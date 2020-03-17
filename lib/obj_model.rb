class ObjModel
  def initialize(filename, has_transparency = false)
    @has_transparency = has_transparency
    @vertices         = []
    @vertices_texture = []
    @vertices_normal  = []
    @faces            = Hash.new

    File.open("gfx/models/#{filename}.obj", 'r').readlines.each do |line|
      line  = line.chomp
      infos = line.split(' ')

      case infos[0]
      when 'mtllib'
        @materials = MaterialCollection.new(infos[1])
      when 'v'
        @vertices.push infos.drop(1).map {|e| e.to_f}
      when 'vt'
        @vertices_texture.push infos.drop(1).map {|e| e.to_f}
      when 'vn'
        @vertices_normal.push infos.drop(1).map {|e| e.to_f}
      when 'g'
        if infos.size > 1
          @current_object = infos.drop(1).join(' ')
          @faces[@current_object] ||= {
            material: nil,
            vertices: Array.new
          }
        end
      when 'usemtl'
        @faces[@current_object][:material] = infos[1]
      when 'f'
        v1 = infos[1].split('/').map {|e| e.to_i - 1}
        v2 = infos[2].split('/').map {|e| e.to_i - 1}
        v3 = infos[3].split('/').map {|e| e.to_i - 1}
        @faces[@current_object][:vertices].push [v1, v2, v3]
      end
    end

    @current_object = nil
  end

  def draw(x = 0, y = 0, z = 0, rot_y = 0)
    if (@has_transparency)
      glEnable(GL_ALPHA_TEST)
      glAlphaFunc(GL_GREATER, 0)
    end
    glPushMatrix
    glTranslatef(x, y, z)
    glRotatef(rot_y, 0, 1, 0) if rot_y != 0
      @faces.each do |object, attributes|
        glBindTexture(GL_TEXTURE_2D, @materials.get_texture_id(attributes[:material]))
        glBegin(GL_TRIANGLES)
          attributes[:vertices].each do |triangle|
            triangle.each do |vertices|
              glTexCoord2d(@vertices_texture[vertices[1]][0], 1 - @vertices_texture[vertices[1]][1])
              glNormal3f(*@vertices_normal[vertices[2]])
              glVertex3f(*@vertices[vertices[0]])
            end
          end
        glEnd
      end
    glPopMatrix
    glDisable(GL_ALPHA_TEST) if @has_transparency
  end
end

class MaterialCollection
  def initialize(filename)
    @materials = Hash.new

    File.open("gfx/models/#{filename}", 'r').readlines.each do |line|
      line = line.chomp
      infos = line.split(' ')

      case infos[0]
      when 'newmtl'
        @current_material = infos[1]
        @materials[@current_material] = Material.new
      when 'd'
        @materials[@current_material].set_diffuse(infos[1].to_f)
      when 'map_Kd'
        @materials[@current_material].set_texture(infos[1])
      end
    end

    @current_material = nil
  end

  def get_texture_id(material)
    @materials[material].texture.get_id
  end
end

class Material
  attr_reader :texture
  def set_diffuse(diffuse_value)
    @diffuse = diffuse_value
  end

  def set_texture(texture_filename)
    @texture = GLTexture.new("gfx/models/#{texture_filename}")
  end
end

class GLTexture
  attr_reader :width, :height

  def initialize(filename)
    gosu_image = filename.is_a?(Gosu::Image) ? filename : Gosu::Image.new(filename, retro: true)
    array_of_pixels = gosu_image.to_blob
    tex_name_buf = ' ' * 4
    glGenTextures(1, tex_name_buf)
    @tex_name = tex_name_buf.unpack('L')[0]
    glBindTexture( GL_TEXTURE_2D, @tex_name )
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, gosu_image.width, gosu_image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  
    @width  = gosu_image.width
    @height = gosu_image.height
    gosu_image = nil
  end

  def get_id
    return @tex_name
  end

  def self.load_tiles(filename, width, height)
    temp_tileset = Gosu::Image.load_tiles(filename, width, height, retro: true)
    textures = []
    temp_tileset.each do |tile|
      textures.push GLTexture.new(tile)
    end
    return textures
  end
end
