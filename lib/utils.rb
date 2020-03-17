class Vector3
  attr_accessor :x, :y, :z

  def initialize(x = 0, y = 0, z = 0)
    @x, @y, @z = x, y, z
  end

  def lerp_to(other, amount = 0.025)
    if Math.sqrt((other.x - @x)**2 + (other.y - @y)**2 + (other.z - @z)**2) < 1.0
      @x, @y, @z = other.x, other.y, other.z
      return true
    end
    @x = @x + amount * (other.x - @x)
    @y = @y + amount * (other.y - @y)
    @z = @z + amount * (other.z - @z)
    return false
  end

  def +(other) 
    @x += other.x
    @y += other.y
    @z += other.z
  end

  def -(other) 
    @x -= other.x
    @y -= other.y
    @z -= other.z
  end
end
