module Reversi
  module Player
    class Human < Player::Base
      def select(board)
        while (@game.canvas.select(board))
          @game.canvas.draw(board)
        end
        board.selected
      end
    end
  end
end
