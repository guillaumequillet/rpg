class Monster
  def initialize(data, position, level)
    @data       = data
    @position   = position
    @level      = level
    
    # texture loading
    @@sprites ||= {}
    unless @@sprites.has_key?(@data['sprite'])
      @@sprites[@data['sprite']] = GLTexture.new("gfx/sprites/#{@data['sprite']}")
    end
  end

  def draw
    sprite = @@sprites[@data['sprite']]

    glEnable(GL_ALPHA_TEST)
    glAlphaFunc(GL_GREATER, 0)

    glBindTexture(GL_TEXTURE_2D, sprite.get_id)

    glPushMatrix
      glTranslatef(@position.x, @position.y, @position.z)
      glScalef(sprite.width, sprite.height, 1)
      glBegin(GL_QUADS)
        glTexCoord2d(0, 0); glVertex3f(-0.5, 1.0, 0.0)
        glTexCoord2d(0, 1); glVertex3f(-0.5, 0.0, 0.0)
        glTexCoord2d(1, 1); glVertex3f(0.5, 0.0, 0.0)
        glTexCoord2d(1, 0); glVertex3f(0.5, 1.0, 0.0)
      glEnd
    glPopMatrix
    glDisable(GL_ALPHA_TEST)
  end
end
