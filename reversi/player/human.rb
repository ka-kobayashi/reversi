module Reversi
  module Player
    class Human < Player::Base
      def select(board)
        while (true)
          if (@game.canvas.select)
            break if board.movable?(board.selected.x, board.selected.y, board.player)
          end
          @game.canvas.draw
        end
        board.selected
      end
    end
  end
end