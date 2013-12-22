module Reversi
  class Canvas
    require "curses"
    include Curses

    attr_accessor :board

    def initialize(board)
      @board = board
      init_screen
    end

    def gets
      draw
      line = ''
      while (c = getch.chr) != "\n"
        line += c
      end
      line
    end

    def draw
      line = 1
      clear

      # x axis
      setpos(line+=1, 1)
      addstr("  " + (0..(@board.width-1)).map{|n| n.to_s + " "}.join())

      # board
      setpos(++line, 1)
      @board.discs.each_with_index do |discs, y|
        setpos(line += 1, 1)
        addstr("#{y} #{discs.map{|d| d.to_s }.join()}")
      end

      # score
      setpos(line += 2, 1)
      addstr "Score : %s%0d, %s%0d" % [Disc.label(Disc::WHITE), @board.scores[Disc::WHITE], Disc.label(Disc::BLACK), @board.scores[Disc::BLACK]]
      setpos(line += 1, 1)
      addstr "Player: %s" % [Disc.label(@board.player)]

      #logs
      @board.logs.each do |log| 
        setpos(line += 1, 1)
        addstr log
      end

      # prompt 
      setpos(0, 1)
      addstr "Command: "

      refresh
    end
  end
end
