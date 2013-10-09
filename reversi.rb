REVERSI_DIR = File.expand_path('reversi', File.dirname(__FILE__)) + "/"
require REVERSI_DIR+'disc.rb'
require REVERSI_DIR+'canvas.rb'
require REVERSI_DIR+'board.rb'
require REVERSI_DIR+'player.rb'
require REVERSI_DIR+'game.rb'

require 'optparse'
options = {}
parser = OptionParser.new
parser.on('-s', '--size=n'){|n| options[:size] = n.to_i}
parser.on('-w', '--white=[name]'){|name| options[:white] = name}
parser.on('-b', '--black=[name]'){|name| options[:black] = name}
parser.on('-i', '--interval=n'){|n| options[:interval] = n.to_f}
parser.parse!(ARGV)

game = Reversi::Game.new
while (true)
  game.run(options)
  sleep 3
end
exit
