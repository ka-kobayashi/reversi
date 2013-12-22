REVERSI_DIR = File.expand_path('reversi', File.dirname(__FILE__)) + "/"
require REVERSI_DIR+'disc.rb'
require REVERSI_DIR+'canvas.rb'
require REVERSI_DIR+'board.rb'
require REVERSI_DIR+'game.rb'

require 'optparse'
options = {}
parser = OptionParser.new
parser.on('--width=n')  {|n| options[:width] = n.to_i}
parser.on('--height=n') {|n| options[:height] = n.to_i}
parser.parse!(ARGV)

game = Reversi::Game.new
while (true)
  game.run(options)
  sleep 5
end
exit
