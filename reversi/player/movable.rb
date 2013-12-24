module Reversi
  module Player
    class Movable < Player::Base
      def configure
        @default_recursive = 3
      end

      def evaluate(board, x, y, player, options = {})
        board.movable.size
      end
    end
  end
end
