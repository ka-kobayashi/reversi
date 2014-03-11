# -*- coding: utf-8 -*-
module Reversi
  class Disc
    SPACE = 0
    WHITE = 1
    BLACK = 2

    WHITE_ICON = "●"
    BLACK_ICON = "◯"
    SPACE_ICON = "　"
    ICON_MAP = {SPACE => SPACE_ICON, WHITE => WHITE_ICON, BLACK => BLACK_ICON}

    attr_accessor :board, :x, :y, :color, :fixed

    def initialize(board, x, y, color = SPACE, fixed = false)
      @board = board
      @color = color
      @x = x
      @y = y
    end

    def movable?(color)
      @board.movable?(self, color)
    end

    def offset(x, y)
      @board.get(@x+x, @y+y)
    end

    def space?
      @color == SPACE
    end

    def white?
      @color == WHITE
    end

    def black?
      @color == BLACK
    end

    def fixed?
      @fixed
    end

    def reverse
      if space?
        SPACE
      else
        white? ? BLACK : WHITE
      end
    end

    def reverse!
      @color = reverse
    end

    def self.icon(color)
      ICON_MAP[color]
    end

    def to_s
      self.class.icon(@color)
    end

    def inspect
      "(%d,%d,%s)" % [@x, @y, to_s]
    end
  end
end
