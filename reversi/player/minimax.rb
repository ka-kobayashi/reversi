module Reversi
  module Player
    class Minimax < Player::Base
      def configure
        @default_recursive = 4
      end

      def evaluate(board, x, y, player, options = {})
        valuation  = board.scores[player]
        valuation += board.movable(player).size * 10
        valuation += board.fixed(player).size * 50
        valuation
      end
    end
  end
end
