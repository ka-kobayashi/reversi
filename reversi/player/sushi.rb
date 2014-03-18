# -*- coding: utf-8 -*-
module Reversi
  module Player
    class Sushi < Player::Base
      def configure
        @depth_basic = 2
        @depth_boost = 4
        @max_depth = @depth_basic
      end
 
      def lookup(depth, board, options = {})
        if depth === 0 && !board.over?
          max_fixed_disc = board.movable.max_by{|disc|
            new_board = board.dup
            new_board.move(disc, board.player)
            count_fixed(new_board)
          }
          new_board = board.dup
          new_board.move(max_fixed_disc, board.player)
          @max_fixed = count_fixed(new_board)
          @max_depth = (@max_fixed - count_fixed(board) > 0) ? @depth_boost : @depth_basic
        else
          return [nil, board.player == @mycolor ? -9999 : 9999] if (count_fixed(board)) < @max_fixed
        end
 
        super(depth, board, options)
      end
 
      def evaluate(disc, board, base_board, options = {})
        player = board.player
        stats = [base_board.stats(player), board.stats(player)]
 
        return (stats[1][:score] - stats[0][:score]) + (stats[1][:fixed].size) ** 2
      end
 
      def count_fixed(board)
        board.stats(@mycolor)[:fixed].size
      end
    end
  end
end

