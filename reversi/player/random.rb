# -*- coding: utf-8 -*-
module Reversi
  module Player
    class Random < Player::Base
      def evaluate(disc, board, base_board, options = {})
        rand(100)
      end
    end
  end
end
