module Reversi
  module Player
    class Random < Player::Base
      def select(board)
        selectable(board).sample
      end
    end
  end
end
