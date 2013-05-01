require 'logger'
$APP_LOGGER = Logger.new(File.dirname(__FILE__) + "/debug.log")

require File.expand_path('../orientation', __FILE__)
require File.expand_path('../player_state', __FILE__)

class BaseBot
	attr_accessor :playerName, :players, :running, :tick, :shooters, :deads
	def initialize player
		@playerName = player
		@players = {}
		@running = true
    @shooters = [] # track players who shot me
    @deads = {} # dead bots
	end
	
	def run
		while self.running
			line = $stdin.readline.strip
			message_from_server = line.split("|")
			#$APP_LOGGER.debug message_from_server
			data = message_from_server[3..-2]
			#$APP_LOGGER.debug data.inspect
			#$APP_LOGGER.debug "#{message_from_server[2].gsub('-','')}"
			if self.respond_to?("#{message_from_server[2].gsub('-','')}")
				if !data.empty?
					self.send("#{message_from_server[2].gsub('-','')}".to_sym,data)
				else
					self.send("#{message_from_server[2].gsub('-','')}".to_sym)
				end
			else
				raise Error, "Bad Line - #{line}"
			end
		end
	end
	
	def startgame playerNames
		playerNames.each do |name|
			self.players[name] = PlayerState.new(name)
    end
	end
	
	def endgame data
    self.running = false
	end
	
	def starttick data
    self.tick = data[0].to_i
	end	
	
	def endtick data
	end
	
	def hit data
		victim, shooter, damage = data
    energy = damage.to_f
    if victim == self.playerName
      self.lastHit = true
      unless self.deads.keys.include?(shooter)
        self.shooters << shooter
        self.shooters = self.shooters.uniq
      end
    end

	end
	
	def miss data
		player, miss_energy = data
    miss_energy.to_f
	end
	
	def fizzle data
    player, fiz_energy = data
    fiz_energy.to_f
	end
	
	def died data
		player = data[0]
    self.deads[player] = self.players[player]
		self.players.delete(player)
    self.shooters.delete(player)
  end
	
	def takeaction
		$stdout.print("|RESPONSE|action|rotate 3.0|rotate-weapon 0.0|move 5.0|fire 0.0|END|\n")
		$stdout.flush
	end
	
	def playerstate data
    playername = data[0]
    playerData = data[1..data.length - 1]
    player = self.players[playername]
    if player
      playerData.each do |state|
          key, value = state.split(" ")
          value = value.to_f
          methods = {"orientation" => "orientation", "weapon-orientation" => "weaponOrientation"}
          methods.keys.include?(key) ? player.send("#{methods[key].to_sym}=",Orientation.new(value)) :
            player.send("#{key.to_sym}=",value)
      end
    end
  end
end
