module Reversi
  module Player
    class Random < Player::Base
      def select(board)
        selectable = []
        board.discs.each_with_index do |discs, y|
          discs.each_with_index do |disc, x|
            selectable << disc if disc.movable?(board.player)
          end
        end
        selectable.sample
      end
    end
  end
end
