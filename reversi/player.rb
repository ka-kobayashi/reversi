require 'benchmark'
require 'thread'

module Reversi
  module Player
    def self.instance(color, game, name, options={})
      name = "human" if name == nil || name == ""
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

      # Reversi::Game から呼び出され、引数で与えられた局面(board)から一手選択し返す。
      def select(board, timeout = 5)
        board = board.dup
        board.canvas = nil
        ret = [nil, 0] #[disc, evaluation]
        @evaluation = 0
        realtime = Benchmark.realtime {
          thinker = Thread.new do
            ret = lookup(0, board)
          end
          killer = Thread.new(thinker, timeout) do |thinker, timeout|
            sleep timeout
            Thread::kill(thinker) if thinker.alive?
          end
          thinker.join

          #選択されなかったとき or Timeout したときは、ランダムで選択
          if ret[0] == nil 
            trace "%s: Timeouted" % [Disc.icon(board.player)]
            ret = [board.movable.sample(1).shift, 0]
          end
        }
        @@realtime[@mycolor] += realtime
        @@evaluation[@mycolor] += @evaluation
        trace "%s: (%d, %d) %5dpt %2.1fs (%5d, %2.2fs)" % [Disc.icon(board.player), ret[0].x, ret[0].y, ret[1], realtime, @evaluation, (@@realtime[@mycolor]*1000)/@@evaluation[@mycolor]]
        ret[0]
      end

      # base_board を基点に探索を行う。探索の深さは @max_depth で指定する。
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
