module Reversi
  module Player
    class Minimax < Player::Base
      def select(board)
        node(board, {:recursive => 3})[0]
      end

      def configure
        @default_recursive = 3
      end

      def evaluate(board, x, y, player, options = {})
        board.movable.size
      end
    end
  end
end