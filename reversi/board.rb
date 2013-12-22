module Reversi
  class Board
    attr_reader :discs, :width, :height, :player, :canvas
    attr_accessor :logs, :selected

    def initialize(options = {})
      options = {:width => 8, :height => 8}.merge(options)
      @width = options[:width]
      @height = options[:height]
      @logs = []
      @directions = [-1, 0, 1].repeated_permutation(2).reject{|x, y| x == 0 && y == 0}
      @canvas = Reversi::Canvas.new(self)
      reset
    end

    def reset
      @player = Disc::WHITE
      @discs = Array.new(@height){|y| Array.new(@width){|x| Reversi::Disc.new(self, x, y) }}
      [-1, 0].repeated_permutation(2).each do |x, y|
        select(@width/2 + x, @height/2 + y).color = (x+y).odd? ? Disc::WHITE : Disc::BLACK
      end
      @selected = select(0, 0)
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

    def reverse(x, y, color, animation = true)
      return unless base = select(x, y)

      @directions.each do |offset_x, offset_y|
        next unless reversible?(base, color, {:x => offset_x, :y => offset_y})
        for i in (1..[@width, @height].max) do
          d = base.offset(offset_x*i, offset_y*i)
          if (d == nil || d.space? || d.color == color)
            break
          end
          d.reverse!
          if animation
            @canvas.draw(false)
            sleep 0.75
          end
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

    def move(x, y, color, animation = true)
      disc = select(x, y)
      raise "already exists: (#{x}, #{y})" unless disc.space?
      raise "can't move: (#{x}, #{y})" unless movable?(x, y, color)

      @selected = disc
      disc.color = color
      @canvas.draw(false) if animation
      reverse(x, y, color)
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
  end
end