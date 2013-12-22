module Reversi
  class Disc
    SPACE = 0
    WHITE = 1
    BLACK = 2

    WHITE_ICON = "●"
    BLACK_ICON = "◯"
    SPACE_ICON = "　"
    ICON_MAP = {SPACE => SPACE_ICON, WHITE => WHITE_ICON, BLACK => BLACK_ICON}

    attr_accessor :board, :x, :y, :color

    def initialize(board, x, y, color = SPACE)
      @board = board
      @color = color
      position(x,y)
    end

    def movable?(color)
      @board.movable?(@x, @y, color)
    end

    def offset(x, y)
      @board.select(@x+x, @y+y)
    end

    def space?
      !(white? || black?)
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
      unless space?
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
  end
end
