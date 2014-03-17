# -*- coding: utf-8 -*-
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

      def enemy
        Disc::WHITE == @mycolor ? Disc::BLACK : Disc::WHITE
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
            trace "%s: Timeouted (%s)" % [Disc.icon(board.player), timeout]
            ret = [board.movable.sample(1).shift, 0]
          end
        }
        @@realtime[@mycolor] += realtime
        @@evaluation[@mycolor] += @evaluation
        trace "%s: (%d, %d) %5dpt %2.1fs (%5d, %2.2fms)" % [Disc.icon(board.player), ret[0].x, ret[0].y, ret[1], realtime, @evaluation, (@@realtime[@mycolor]*1000)/@@evaluation[@mycolor]]
        ret[0]
      end

      # board を基点に探索を行う。探索の深さは @max_depth で指定する。
      def lookup(depth, board, options = {})
        # これ以上探索しない場合は、現在の局面を評価値として返す。
        if depth >= @max_depth || board.over?
          return [nil, evaluate(options[:moved], board, board, options)]
        end

        # 現在の選択可能な打ち手について、子ノードの評価値を求める。
        plans = {}
        board.movable.each do |disc|
          new_board = board.dup
          new_board.move(disc, board.player)
          @evaluation += 1
          plans[disc] = lookup(depth+1, new_board, options.merge({:moved => disc}))[1]
        end

        # 子ノードの評価値のうち、最も有効となる手を選択肢、ノードの評価値として返す。
        if board.player == @mycolor
          disc = plans.min{|a,b| a[1] <=> b[1]}[0]
        else
          disc = plans.max{|a,b| a[1] <=> b[1]}[0]
        end
        return [disc, plans[disc]] #打ち手 と 評価値を返す。
      end

      def evaluate(disc, board, base_board, options = {})
        0
      end
    end
  end
end
