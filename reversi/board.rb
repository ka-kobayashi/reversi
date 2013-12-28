module Reversi
  class Board
    attr_reader :discs, :width, :height, :player, :canvas, :turn
    attr_accessor :logs, :selected, :canvas

    def initialize(options = {})
      @options = options
      @width = options[:width]
      @height = options[:height]
      @logs = []
      @directions = [-1, 0, 1].repeated_permutation(2).reject{|x, y| x == 0 && y == 0}
      reset
    end

    def dup
      Marshal.load(Marshal.dump(self))
    end

    def reset
      @player = Disc::WHITE
      @discs = Array.new(@height){|y| Array.new(@width){|x| Reversi::Disc.new(self, x, y) }}
      [-1, 0].repeated_permutation(2).each do |x, y|
        select(@width/2 + x, @height/2 + y).color = (x+y).odd? ? Disc::WHITE : Disc::BLACK
      end
      @selected = select(0, 0)
      @turn = 1
    end

    def pass?(player = @player)
      @discs.each_with_index do |line, y|
        line.each_with_index do |disc, x|
          return false if movable?(disc.x, disc.y, player)
        end
      end
      return true
    end

    def over?
      scores[Disc::SPACE] == 0 || (pass?(Disc::WHITE) && pass?(Disc::BLACK))
    end

    def next_player(player = @player)
      (player == Disc::WHITE) ? Disc::BLACK : Disc::WHITE
    end

    def next_player!
      @player = next_player
    end

    def fixed(player = @player)
      discs = []
      @discs.each do |line|
        line.each do |disc|
          discs << disc if (disc.color == player && fixed?(disc.x, disc.y))
        end
      end
      discs
    end

    def fixed?(x, y)
      (fixed_line?(x, y, -1,  0) || fixed_line?(x, y, 1, 0)) && #横
      (fixed_line?(x, y,  0, -1) || fixed_line?(x, y, 0, 1)) && #縦
      (fixed_line?(x, y, -1, -1) || fixed_line?(x, y, 1, 1))    #斜
    end

    def fixed_line?(x, y, offset_x, offset_y)
      return false if (base = select(x, y)) == nil || base.space?

      color = base.color
      for i in (1..[@width, @height].max) do
        d = base.offset(offset_x*i, offset_y*i)
        return false unless (d == nil || d.color == color)
      end
      return true
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
          @canvas.reversed if @canvas
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

    def movable?(x, y, player = @player) 
      if (base = select(x, y)) == nil || !base.space?
        return false
      end
      @directions.each do |offset_x, offset_y|
        if reversible?(base, player, {:x => offset_x, :y => offset_y})
          return true
        end
      end
      return false
    end

    def movable(player = @player)
      movables = []
      @discs.each do |line|
        line.each do |disc|
          movables << disc if disc.movable?(player)
        end
      end
      movables
    end

    def move(x, y, player = @player)
      disc = select(x, y)
      raise "already exists: (#{x}, #{y})" unless disc.space?
      raise "can't move: (#{x}, #{y})" unless movable?(x, y, player)

      @selected = disc
      disc.color = player
      @canvas.moved if @canvas
      reverse(x, y, player)
      next_player! 
      if pass?
        @logs << Disc.icon(@player) + ": PASS"
        next_player! 
      end
      @turn += 1
    end

    def select(x, y)
      return nil if x < 0 || y < 0
      begin
        @discs[y.to_i][x.to_i]
      rescue
        nil
      end
    end

    def scores
      colors = @discs.map{|line| line.map{|d| d.color}}.flatten
      Hash[*[Disc::SPACE, Disc::WHITE, Disc::BLACK].map{|c| [c, colors.count(c)]}.flatten]
    end

    def winner?(player = @player)
      s = scores
      s[player] > s[next_player(player)]
    end
  end
end
