require File.expand_path('../base_bot', __FILE__)
class RubyGunnerBot < BaseBot
  attr_accessor :lastFired, :lastHit, :shooters

  def initialize name
    super(name)
    @lastFired = 0  # track the tick when the last shot was fired
    @lastHit = false # track when last hit
  end

  def takeaction
      myPlayer = self.players[playerName]
      currentOrientation = myPlayer.orientation + myPlayer.weaponOrientation
      currentOrientation.normalize
      rotationalDistances = []
      bots_to_be_fired = @shooters.empty? ? self.players.values : self.players.values.select{|client| @shooters.include?(client.name)}
      bots_to_be_fired.reject! {|bot| bot.name == playerName}
      #aimed_bots = bots_to_be_fired.select{|bot| !is_any_dead_bot_on_the_path?(myPlayer,bot)}
      bots_to_be_fired.each do |client|
        if client.name != playerName
          orientation = Orientation.get_orientation(myPlayer,client)
          delta = currentOrientation.diff_clockwise(orientation)
          #dist = Orientation.direct_distance_between_two(myPlayer,client)
          rotationalDistances << [delta.relative.abs, delta.relative, client]
          #rotationalDistances << [delta.relative.abs, delta.relative, client,dist]
        end
      end

      closest = rotationalDistances.min {|a,b| a[0] <=> b[0]}
      #closest = rotationalDistances.min {|a,b| a[3] <=> b[3]}

      sign = closest[1] < 0 ? -1.0 : 1.0
      distance = closest[0]
      rotate, rotateWeapon = set_rotations(distance, sign)

      fire = fire_energy(distance,closest.last)
      move = move_when_being_shot(myPlayer,rotate,rotateWeapon)

      $stdout.write("|RESPONSE|action|rotate #{rotate.round(3)}|rotate-weapon #{rotateWeapon.round(3)}|move #{move.round(3)}|fire #{fire.round(3)}|END|\n")
      $stdout.flush
  end

  def move_when_being_shot myPlayer, rotate,rotateWeapon
    move = 0.0
    if self.last_hit?
      move = 5.0
      while is_outside_maze_boundary?(move,myPlayer,rotate,rotateWeapon)
        move -= 3
        if move < -5
          move = 0.0
          break
        end
      end
      self.lastHit = false
    end
    move
  end

  def is_outside_maze_boundary? move, myPlayer, rotate,rotateWeapon
    myPlayer.orientation.degrees += rotate
    myPlayer.weaponOrientation.degrees += rotateWeapon
    myPlayer.orientation.degrees = MathUtil.clamp(myPlayer.orientation.degrees % 360.0,0.0,359.999)
    myPlayer.weaponOrientation.degrees = MathUtil.clamp(myPlayer.orientation.degrees % 360.0,0.0,359.999)
    r = myPlayer.orientation.degrees * Math::PI / 180
    x = Math.sin(r) * move
    y = Math.cos(r) * move
    myPlayer.x += x
    myPlayer.y += y
    !((0..999).cover?(myPlayer.x) and (0..999).cover?(myPlayer.y))
  end

  def fire_energy distance, client
    fire = 0.0
    if distance < 10 and (self.tick - self.lastFired) > 4
      client_energy =  client.energy
      fire = client_energy > 160.000 ? 5.0 : (client_energy > 120.000 ? 4.0 : (client_energy > 80.000 ? 3.0 : (client_energy > 40.000 ? 2.0 : (client_energy > 0 ? 1.0 : 0.0))))
      self.lastFired = self.tick
    end
    fire
  end

  def set_rotations distance, direction
    if distance > 18
      [9 * direction,9 * direction]
    elsif distance > 9
      [9 * direction, (distance - 9) * direction]
    else
      [distance * direction, 0.0]
    end
  end

  def last_hit?
    self.lastHit
  end

  #def is_any_dead_bot_on_the_path? myplayer,bot
  #  if self.deads.empty?
  #    $APP_LOGGER.debug "deads empty"
  #    return false
  #  else
  #    self.deads.each do |name, dead_bot|
  #       $APP_LOGGER.debug "#{dead_bot.x}  -- #{bot.x} -- #{myplayer.x}"
  #       if (dead_bot.x == myplayer.x and myplayer.x == bot.x) or (dead_bot.y == myplayer.y and myplayer.y == bot.y)
  #         return true
  #       else
  #         to =  (dead_bot.x - myplayer.x) / (bot.x - myplayer.x)
  #         t1 =  (dead_bot.y - myplayer.y) / (bot.y - myplayer.y)
  #         $APP_LOGGER.debug "#{to}   ----   #{t1}"
  #         if to.round(2) == t1.round(2) and to >=0 and to <= 1
  #           return true
  #         end
  #       end
  #    end
  #    return false
  #  end
  #end

end

begin
  RubyGunnerBot.new(ARGV.first).run
rescue => e
  $APP_LOGGER.debug e.message
  $APP_LOGGER.debug e.backtrace.join("\n")
end