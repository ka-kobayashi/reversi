# -*- coding: utf-8 -*-
module Reversi
  class Board
    include Reversi::Logger

    attr_accessor :size, :discs, :player, :logs, :selected, :canvas, :stats
    @@directions = [-1, 0, 1].repeated_permutation(2).reject{|x, y| x == 0 && y == 0}

    def initialize(options = {})
      @options = options
      @size = options[:size]
      @logs = []
    end

    def directions
      @@directions
    end

    def initialize_copy(base)
      @discs = Array.new(@size*@size)
      for i in (0..(@size*@size-1)) do
        @discs[i] = base.discs[i].dup
        @discs[i].board = self
      end
      @logs = []
    end

    def reset!
      @player = (@options[:first_player] ? @options[:first_player] : Disc::WHITE)
      @discs = Array.new(@size*@size)
      for y in (0..(@size-1)) do
        for x in (0..(@size-1)) do
          @discs[(x + y*@size)] = Disc.new(self, x, y)
        end
      end
      [-1, 0].repeated_permutation(2).each do |x, y|
        get(@size/2+x, @size/2+y).color = (x+y).even? ? Disc::WHITE : Disc::BLACK
      end
      @selected = get(0, 0)
      stats!
      self
    end

    def pass?(player = @player)
      @discs.each do |disc|
        return false if movable?(disc, player)
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
      @discs.select{|d| (d.color == player && fixed?(d))}
    end

    def fixed?(disc)
      return true  if disc.fixed?
      return false if disc.space?

      disc.fixed =
      (fixed_line?(disc, -1,  0) || fixed_line?(disc, 1,  0)) && #横
      (fixed_line?(disc,  0, -1) || fixed_line?(disc, 0,  1)) && #縦
      (fixed_line?(disc, -1,  1) || fixed_line?(disc, 1, -1)) && #斜
      (fixed_line?(disc, -1, -1) || fixed_line?(disc, 1,  1))    #斜
    end

    def fixed_line?(base, x, y)
      return false if base.space?

      color = base.color
      for i in (1..@size-1) do
        d = base.offset(x*i, y*i)
        break if d == nil
        return false unless d.color == color
      end
      return true
    end

    def reverse(base, color)
      directions.each do |x, y|
        next unless reversible?(base, color, {:x => x, :y => y})
        for i in (1..@size) do
          d = base.offset(x*i, y*i)
          # logger.trace("%s: %s (%d,%d)" % [base, d, x*i, y*i])
          if (d == nil || d.space? || d.color == color)
            break
          end
          d.reverse!
          @canvas.reversed(self) if @canvas
        end
      end
      self
    end

    def reversible?(base, color, offset)
      for i in (1..@size) do
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

    def movable?(base, player = @player) 
      return false unless base.space?

      directions.each do |x, y|
        if reversible?(base, player, {:x => x, :y => y})
          return true
        end
      end
      return false
    end

    def movable(player = @player)
      @discs.select{|d| d.movable?(player)}
    end

    def move(disc, player = @player)
      disc = get(disc.x, disc.y)
      @selected = disc
      disc.color = player
      @canvas.moved(self) if @canvas
      reverse(disc, player)
      stats!
      next_player! 
      if pass?
        @logs << Disc.icon(@player) + ": PASS"
        next_player! 
      end
      self
    end

    def get(x, y)
      if (x < 0 || x >= @size) 
        return nil
      end
      if (y < 0 || y >= @size) 
        return nil
      end
      @discs[x + y*@size]
    end

    def stats!
      @stats = {}
      [Disc::WHITE, Disc::BLACK].each do |player|
        @stats[player] = {:score => scores[player], :movable => movable(player), :fixed => fixed(player)}
      end
      @stats
    end

    def stats(player = @player) 
      stats! unless @stats
      @stats[player]
    end

    def scores
      colors = @discs.map{|d| d.color}
      Hash[*[Disc::SPACE, Disc::WHITE, Disc::BLACK].map{|c| [c, colors.count(c)]}.flatten]
    end

    def score(player = @player)
      @stats[player][:score]
    end

    def winner
      white = score(Disc::WHITE)
      black = score(Disc::BLACK)

      return nil if (white == black)
      return white > black ? Disc::WHITE : Disc::BLACK
    end

    def winner?(player = @player)
      score(player) > score(next_player(player))
    end
  end
end
