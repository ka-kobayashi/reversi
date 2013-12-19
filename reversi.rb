module Reversi
  class Game
    attr_reader :board

    def initialize()

    end

    def run(options = {})
      @board = Reversi::Board.new(options)
      while (!@board.over?)
        @board.draw
        while (true)
          print ":"
          pos = STDIN.gets.strip
          break @board.movable?(pos[0], pos[1], @board.player)
        end
        @board.move(pos[0], pos[1], @board.player)
        @board.next_player!
        p @board.score
      end
    end
  end

  class Board
    attr_reader :discs, :width, :height, :turn, :player
    attr_accessor :logs
    @discs
    @width
    @height
    @player
    @turn
    @logs

    def initialize(options = {})
      options = {:width => 8, :height => 8}.merge(options)
      @width = options[:width]
      @height = options[:height]
      @turn = 0
      @player = Disc::WHITE
      @logs = []

      @discs = Array.new(@height){|y| Array.new(@width){|x| Reversi::Disc.new(self, x, y) }}
      [-1, 0].repeated_permutation(2).each do |x, y|
        select(@width/2 + x, @height/2 + y).color = (x+y).odd? ? Disc::WHITE : Disc::BLACK
      end
    end

    def over?
      @turn == (@width * @height) - 1
    end

    def next_player!
      @player = (@player == Disc::WHITE ? Disc::BLACK : Disc::WHITE)
    end

    def reverse(x, y, color)
      base = select(x, y)
      return if base == nil

      [-1, 0, 1].repeated_permutation(2).reject{|x, y| x == 0 && y == 0}.each do |ox, oy|
        for i in (1..[@width, @height].max) do
          d = base.offset(ox*i, oy*i)
          if (d == nil || d.space? || d.color == color)
            break
          end
          d.reverse!
        end
      end
    end

    def movable?(x, y, color) 
      base = select(x, y)
      return false if base == nil || !base.space?

      [-1, 0, 1].repeated_permutation(2).reject{|x, y| x == 0 && y == 0}.each do |ox, oy|
        for i in (1..[@width, @height].max) do
          d = base.offset(ox*i, oy*i)
          if (d == nil || d.space? || (d.color == color && i == 1))
            break
          end
          if (d.color == color && i > 1)
            return true
          end
        end
      end
      return false
    end

    def move(x, y, color)
      disc = select(x, y)
      raise "already exists: (#{x}, #{y})" unless disc.space?
      raise "can't move: (#{x}, #{y})" unless movable?(x, y, color)

      disc.color = color
      reverse(x, y, color)
    end

    def select(x, y)
      begin
        @discs[y.to_i][x.to_i]
      rescue
        nil
      end
    end

    def draw
      border = ''

      # puts "  " + (0..(@width-1)).map{|n| (97+n).chr + " "}.join("") + "\n"
      puts "  " + border + (0..(@width-1)).map{|n| n.to_s + " "}.join(border) + border + "\n"
      @discs.each_with_index do |line, y|
        puts "#{y} #{border}#{line.map{|disc| disc.to_s }.join(border)}#{border}"
      end

      puts "Player: %s" % [Disc.label(@player)]
      puts "Score %s:%d, %s:%d" % [Disc.label(Disc::WHITE), score[Disc::WHITE], Disc.label(Disc::BLACK), score[Disc::BLACK]]
      puts
      puts @logs.join("\n")
    end

    def score
      colors = @discs.map{|line| line.map{|d| d.color}}.flatten
      Hash[*[Disc::SPACE, Disc::WHITE, Disc::BLACK].map{|c| [c, colors.count(c)]}.flatten]
    end
  end

  class Disc
    SPACE = 0
    WHITE = 1
    BLACK = 2

    WHITE_ICON = "●"
    BLACK_ICON = "◯"
    SPACE_ICON = "　"
    MOVABLE_ICON = '[]'

    attr_accessor :border, :x, :y, :color

    @board = nil
    @x = nil
    @y = nil
    @color = nil

    def initialize(board, x, y, color = SPACE)
      @board = board
      position(x,y)
      @color = color
    end

    def offset(x, y)
      @board.select(@x + x, @y + y)
    end

    def space?
      !white? && !black?
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
      return SPACE_ICON if (color == nil) 
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

game = Reversi::Game.new
game.run
exit
