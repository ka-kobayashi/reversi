# -*- coding: utf-8 -*-
module Reversi
  module Player
    class Random < Player::Base
      def lookup(depth, board, options = {})
        @evaluation += 1
        [board.movable.sample(1).shift, 0]
      end
    end
  end
end
