require 'benchmark'

module Reversi
  module Player
    def self.instance(color, game, name, options={})
      name = "human" unless name || name == ""
      require "#{File.dirname(__FILE__)}/player/#{name}.rb"
      Reversi::Player.const_get(name.to_s.capitalize).new(color, game, name, options)
    end

    class Base
      include Reversi::Logger

      attr_reader :mycolor, :game, :name, :options, :max_depth

      def initialize(mycolor, game, name, options)
        @@evaluation = {Disc::WHITE => 0, Disc::BLACK => 0}
        @@realtime = {Disc::WHITE => 0.0, Disc::BLACK => 0.0}
        @mycolor = mycolor
        @game = game
        @size = game.board.size
        @name = name
        @options = options
        @max_depth = 0
        @debug = false
        configure
      end

      def configure
      end

      def human?
        @name == "human"
      end

      def trace(message)
        @game.board.logs << message
      end

      def select(board)
        board = board.dup
        board.canvas = nil
        ret = [nil, 0] #[disc, evaluation]
        @evaluation = 0
        @@realtime[@mycolor] += Benchmark.realtime {
          ret = lookup(0, board)
        }
        @@evaluation[@mycolor] += @evaluation
        trace "%s: (%d, %d) %5dpt (%5d, %4.2fms)" % [Disc.icon(board.player), ret[0].x, ret[0].y, ret[1], @evaluation, (@@realtime[@mycolor]*1000)/@@evaluation[@mycolor]]
        ret[0]
      end

      def lookup(depth, base_board, options = {})
        plans = {}
        base_board.movable.each do |disc|
          board = base_board.dup
          board.move(disc, board.player)
          @evaluation += 1
          plans[disc] = evaluate(disc, board, base_board, options)
          if depth < @max_depth && !board.over? 
            plans[disc] += (board.player == @mycolor ? 1 : -1) * lookup(depth+1, board, options)[1]
          end
        end
        return [nil, 0] if plans.size < 1

        disc = plans.max{|a,b| a[1] <=> b[1]}[0]
        return [disc, plans[disc]]
      end

      def evaluate(disc, board, base_board, options = {})
        0
      end
    end
  end
end
