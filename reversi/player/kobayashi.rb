# -*- coding: utf-8 -*-
module Reversi
  module Player
    class Kobayashi < Player::Base
      def configure
        @max_depth = 2
        initialize_point_score
      end

      def lookup(depth, board, options = {})
        # これ以上探索しない場合は、現在の局面を評価値として返す。
        if board.over?
          return [nil, board.player == @mycolor ? 2147483647 : -2147483647]
        end
        if depth > @max_depth
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
        player = board.player
        stats = [base_board.stats(player), board.stats(player)]
        if @debug
          trace("%s: (%d, %d) - score=%d, movable=%d, fixed=%d" % [
            Disc.icon(player), disc.x, disc.y,
            stats[1][:score] - stats[0][:score],
            stats[1][:movable].size,
            stats[1][:fixed].size - stats[0][:fixed].size])
        end

        valuation  = 0
        valuation += (stats[1][:movable].size) * 25
        valuation += (stats[1][:fixed].size - stats[0][:fixed].size) * 500
        valuation += point_score(disc) * 50
        return valuation
      end

      def point_score(disc)
        @point_score[disc.x][disc.y]
      end

      def initialize_point_score()
        @point_score = Array.new(@size){|x| Array.new(@size){|y| -1}}

        [0, @size-1].repeated_permutation(2).each do |x, y|
          #四隅 と その周辺
          @point_score[x][y] = 30
          base = @game.board.get(x, y)
          @game.board.directions.each do |ox, oy|
            if (d = base.offset(ox, oy))
              @point_score[d.x][d.y] = (ox.abs == oy.abs ? -15 : -12) 
            end
          end

          # 四隅の周辺の周囲
          [0, 2, -2].repeated_permutation(2).each do |ox, oy|
            next if ox == 0 && oy == 0
            if (d = base.offset(ox, oy))
              @point_score[d.x][d.y] = 0
            end
          end
        end

        # 辺の内側
        (0..(@size-1)).each do |x|
          (0..(@size-1)).each do |y|
            if ((x == 1 || y == 1 || x == (@size - 1) || y == (@size - 1)) && @point_score[x][y] == -1)
              @point_score[x][y] = -3
            end
          end
        end

        # デバッグ
        (0..(@size-1)).each{|x| (0..(@size-1)).each{|y| print "%04s" % [@point_score[x][y]]}; print "\n" }
      end
    end
  end
end
