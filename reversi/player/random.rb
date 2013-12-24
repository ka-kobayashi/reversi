module Reversi
  module Player
    class Random < Player::Base
      def evaluate(board, x, y, player, options = {})
        rand(100)
      end
    end
  end
end
