REVERSI_DIR = File.expand_path('.', File.dirname(__FILE__))
require REVERSI_DIR+'/reversi/logger.rb'
require REVERSI_DIR+'/reversi/disc.rb'
require REVERSI_DIR+'/reversi/canvas.rb'
require REVERSI_DIR+'/reversi/board.rb'
require REVERSI_DIR+'/reversi/player.rb'
require REVERSI_DIR+'/reversi/game.rb'

require 'optparse'
options = {}
parser = OptionParser.new
parser.on('-s', '--size=n'){|n| options[:size] = n.to_i}
parser.on('-w', '--white=[name]'){|name| options[:white] = name}
parser.on('-b', '--black=[name]'){|name| options[:black] = name}
parser.on('-i', '--interval=n'){|n| options[:interval] = n.to_f}
parser.on('-l', '--load=file'){|file| options[:load] = file}
parser.on('-t', '--timeout=[sec]'){|sec| options[:timeout] = sec}
parser.parse!(ARGV)

game = Reversi::Game.new
game.run(options)
exit
