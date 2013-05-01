require File.expand_path('../orientation', __FILE__)
class PlayerState
	attr_accessor :name, :x, :y, :orientation, :weaponOrientation, :energy
	def initialize(name="", x=0.0, y=0.0, orientation=0.0, weaponOrientation=0.0, energy=0.0)
        @name = name
        @x = x
        @y = y
        @orientation = Orientation.new(orientation)
        @weaponOrientation = Orientation.new(weaponOrientation)
        @energy = energy
	end	
end

class MathUtil
  def self.clamp(val,min,max)
    clamped_value = [min,[val,max].min].max.round(3)
  end
end