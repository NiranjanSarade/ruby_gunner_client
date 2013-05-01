ruby_gunner_client
==================

- Written by Niranjan Sarade

This is a client written in Ruby language (Ruby 1.9.3) which is a game where bots drive tanks around and fire at each other.

Description
=============
This is a game where players write bots in their programming language of choice, and these bots drive tanks around and fire at each other. This is a client written in Ruby language (Ruby 1.9.3) and the server is written in Python. (not shared here)

Details
=========
A game is made up of a series of ticks, where each tick every bot that is still alive is given the opportunity to take 4 actions.
These actions are:
  •	rotate
	•	rotate-weapon
	•	move
	•	fire
rotate is a float, clamped between -9.0 and 9.0, and specifies the amount the user wants to rotate this tick. Note that North is 0.0, East is 90.0.
rotate-weapon is a float, clamped between -9.0 and 9.0, and specifies the amount the user wants to rotate the weapon this tick.
move is a float, clamped between -5.0 and 10.0, and specifies the distance the user wants to move (negative is backwards, positive is forwards).
fire is a float, clamped between 0.0 and 5.0, and specifies the energy to invest in firing the cannon. The cannon is considered to be fast enough of a shot that the hits are calculated as part of the same tick. It is possible for two bots to destroy each other as part of the same tick. NOTE: Your gun takes time to recharge, and can only be fired after 5 ticks of cooldown. If you fire before it is recharged, the shot fizzles, meaning you lose the energy invested, and your cooldown period starts over, but no shot is actually fired. You start the game with your gun ready to fire.
All of the above actions allow a value of 0.0, which is equivalent to no action.
To avoid confusion across languages and platforms, all floats will be rounded at 3 decimal places (e.g., 3.14159 will become 3.142).
If you go outside of the area of the arena (0-999 in x and y directions), your bot dies. There is no collision detection between bots, nor any punishment for driving through another bot. Any shot, however, only hits the first bot it intersects with (including dead bots). 
If you respond with an unparsable message, your bot dies.
You start the game with 3000 energy.

Interface
============
Communication will be via stdin and stdout for the client programs, where a single line correlates to a single message either from or to the server, and the vertical bar is used to separate parts of the message. As a result, your username cannot have any whitespace or vertical bars in it.
All communication will follow the following format:
|MESSAGE_TYPE|MESSAGE_KEY|DATA|END|
There is a newline after the last bar after END.
Data can have multiple fields in it, or not be included at all.
Some fields are key value pairs, and these separate the key and the value with a space.

Examples  
===========
# start game

|INFO|start-game|jake|jimmy|END|

# game over, with jake winning

|INFO|end-game|jake 1|jimmy 0|END|

# start tick #3

|INFO|start-tick|3|END|

# end tick #3

|INFO|end-tick|3|END|

# jake's current state. Note that weapon-orientation is an offset from the over-all bot orientation.

|INFO|player-state|jake|x 200.000|y 800.000|orientation 9.0|weapon-orientation 0.0|energy 721.345|END|

# jake shot jimmy for 42.8 points of damage

|INFO|hit|jimmy|jake|42.8|END|

# jake fired a shot worth 5.0 energy points (200.0 potential damage), but missed hitting anyone

|INFO|miss|jake|5.0|END|

# jimmy tried to fire a shot worth 4.3 energy points, but it fizzled due to not waiting long enough

|INFO|fizzle|jimmy|4.3|END|

|INFO|died|jimmy|END|
