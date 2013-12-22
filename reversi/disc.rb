module Reversi
  class Disc
    SPACE = 0
    WHITE = 1
    BLACK = 2

    WHITE_ICON = "●"
    BLACK_ICON = "◯"
    SPACE_ICON = "　"
    MOVABLE_ICON = '[]'

    attr_accessor :board, :x, :y, :color

    def initialize(board, x, y, color = SPACE)
      @board = board
      @color = color
      position(x,y)
    end

    def offset(x, y)
      @board.select(@x + x, @y + y)
    end

    def space?
      !(white? || black?)
    end

    def exists?
      !space?
    end

    def white?
      @color == WHITE
    end

    def black?
      @color == BLACK
    end

    def position(x, y)
      @x = x
      @y = y
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

    def inspect
      "(%s, %s, %s)" % [@x, @y, @color]
    end

    def self.label(color)
      return SPACE_ICON if color == SPACE 
      return WHITE_ICON if color == WHITE
      return BLACK_ICON if color == BLACK
    end

    def to_s
      if exists?
        white? ? WHITE_ICON : BLACK_ICON
      else
        @board.movable?(@x, @y, @board.player) ? MOVABLE_ICON :  SPACE_ICON
      end
    end
  end
end
