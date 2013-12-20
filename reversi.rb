module Reversi
  class Game
    attr_reader :board

    def initialize()
    end

    def run(options = {})
      @board = Reversi::Board.new(options)
      @board.draw
      while (!@board.over?)
        while (true)
          print ":"
          pos = STDIN.gets.strip
          break if @board.movable?(pos[0], pos[1], @board.player)
        end
        @board.move(pos[0], pos[1], @board.player)
        @board.next_player! 
        if @board.pass?
          @board.next_player! 
        end
        @board.draw
      end
    end
  end

  class Board
    attr_reader :discs, :width, :height, :turn, :player
    attr_accessor :logs

    def initialize(options = {})
      options = {:width => 3, :height => 3}.merge(options)
      @width = options[:width]
      @height = options[:height]
      @turn = 0
      @player = Disc::WHITE
      @logs = []
      @directions = [-1, 0, 1].repeated_permutation(2).reject{|x, y| x == 0 && y == 0}

      @discs = Array.new(@height){|y| Array.new(@width){|x| Reversi::Disc.new(self, x, y) }}
      [-1, 0].repeated_permutation(2).each do |x, y|
        select(@width/2 + x, @height/2 + y).color = (x+y).odd? ? Disc::WHITE : Disc::BLACK
      end
    end

    def pass?(color = nil)
      color = @player unless color
      @discs.each_with_index do |line, y|
        line.each_with_index do |disc, x|
          return false if movable?(disc.x, disc.y, color)
        end
      end
      return true
    end

    def over?
      scores[Disc::SPACE] == 0 || (pass?(Disc::WHITE) && pass?(Disc::BLACK))
    end

    def next_player!
      @player = (@player == Disc::WHITE ? Disc::BLACK : Disc::WHITE)
    end

    def reverse(x, y, color)
      return unless base = select(x, y)

      @directions.each do |offset_x, offset_y|
        next unless reversible?(base, color, {:x => offset_x, :y => offset_y})
        for i in (1..[@width, @height].max) do
          d = base.offset(offset_x*i, offset_y*i)
          if (d == nil || d.space? || d.color == color)
            break
          end
          d.reverse!
        end
      end
    end

    def reversible?(base, color, offset)
      for i in (1..[@width, @height].max) do
        d = base.offset(offset[:x]*i, offset[:y]*i)
        if (d == nil || d.space? || (d.color == color && i == 1))
          break
        end
        if (d.color == color && i > 1)
          return true
        end
      end
      return false
    end

    def movable?(x, y, color) 
      if (base = select(x, y)) == nil || !base.space?
        return false
      end

      @directions.each do |offset_x, offset_y|
        if reversible?(base, color, {:x => offset_x, :y => offset_y})
          return true
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
      puts "Score : %s=%d, %s=%d" % [Disc.label(Disc::WHITE), scores[Disc::WHITE], Disc.label(Disc::BLACK), scores[Disc::BLACK]]
      puts
      puts @logs.join("\n")
    end

    def scores
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

game = Reversi::Game.new
game.run
exit
