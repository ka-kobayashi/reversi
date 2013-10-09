module Reversi
  module Player
    # http://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%8B%E3%83%9E%E3%83%83%E3%82%AF%E3%82%B9%E6%B3%95
    class Minimax < Player::Base
      def select(board)
        plan = {}
        selectable(board).each do |d|
          plan[d] = evaluate(board, d.x, d.y)
        end
        plan.max{|a,b| a[1] <=> b[1]}[0]
      end

      def evaluate(board, x, y)
        player = board.player
        board = board.clone
        board.move(x, y, player)
        board.scores[player] 
      end
    end
  end
end
