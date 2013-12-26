module Reversi
  module Player
    class Minimax < Player::Base
      def configure
        @default_recursive = 3
      end

      def evaluate(board, x, y, player, options = {})
        valuation  = board.scores[player]
        valuation += board.movable.size * 10
        valuation += board.fixed(player).size * 50
      end
    end
  end
end
