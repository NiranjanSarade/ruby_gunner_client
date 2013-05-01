class Orientation
  attr_accessor :degrees

  def initialize degrees
    @degrees = degrees
    self.normalize
  end

  def normalize
    while @degrees < 0
      @degrees += 360.0
    end
    while @degrees > 360
      @degrees -= 360.0
    end
  end

  def diff_clockwise(other)
      Orientation.new(other.degrees - self.degrees)
  end

  def diff_counter_clockwise(other)
      Orientation.new(self.degrees - other.degrees)
  end

  def relative
    relative_degrees = @degrees <= 180 ? @degrees : @degrees - 360.0
    relative_degrees
  end

  def self.get_orientation(p1,p2)
    dx = p2.x - p1.x
    dy = p2.y - p1.y
    radianOrientation = Math.atan2(dy, dx)
    Orientation.new(90.0 - (radianOrientation * 180 / Math::PI))
  end

  def eql? object
    if object.equal?(self)
      return true
    elsif !self.class.equal?(object.class)
      return false
    end
    self.degrees == object.degrees
  end

  def +(other)
      Orientation.new(self.degrees + other.degrees)
  end

  def self.direct_distance_between_two(p1,p2)
    dx = p2.x - p1.x
    dy = p2.y - p1.y
    Math.sqrt(dx*dx + dy*dy)
  end
end
