# -*- coding: utf-8 -*-
module Reversi
  module Player
    class Kobayashi < Player::Base
      def configure
        @max_depth = 2
        initialize_point_score
      end

      # base_board を基点に探索を行う。探索の深さは @max_depth で指定する。
      def lookup(depth, base_board, options = {})
        plans = {}
        threads = {}
        base_board.movable.each do |disc|
          threads[disc] = Thread.new do
            # logger.trace "new lookup thread for #{disc}"
            board = base_board.dup
            board.move(disc, board.player)
            plans[disc] = evaluate(disc, board, base_board, options)
            @evaluation += 1
            if depth < @max_depth && !board.over? 
              plans[disc] += (board.player == @mycolor ? 1 : -1) * lookup(depth+1, board, options)[1]
            end
          end
        end
        threads.each_pair do |disc, t|
          # logger.trace "join lookup thread for #{disc}"
          t.join
        end
        return [nil, 0] if plans.size < 1

        disc = plans.max{|a,b| a[1] <=> b[1]}[0]
        return [disc, plans[disc]]
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

        valuation  = (stats[1][:score] - stats[0][:score])
        valuation += (stats[1][:movable].size) * 25
        valuation += (stats[1][:fixed].size - stats[0][:fixed].size) * 500
        valuation += point_score(disc)
        valuation
      end

      def point_score(disc)
        @point_score[disc.x][disc.y]
      end

      def initialize_point_score()
        @point_score = Array.new(@size){|x| Array.new(@size){|y| 0}}

        #四隅 と その周辺
        [0, @size-1].repeated_permutation(2).each do |x, y|
          @point_score[x][y] = 250
          base = @game.board.get(x, y)
          @game.board.directions.each do |ox, oy|
            sc = base.offset(ox, oy)
            @point_score[sc.x][sc.y] = -250 if sc
          end
        end
      end
    end
  end
end
