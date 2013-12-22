require "curses"

module Reversi
  class Canvas
    include Curses
    attr_reader :board

    PAIR_DISC = 0
    PAIR_MOVABLE = 1
    PAIR_SELECTED = 2
    PAIR_AXIS = 3
    PAIR_INFO = 4

    def initialize(board)
      @board = board
      init_screen
      stdscr.keypad true
      start_color

      init_pair(PAIR_DISC,     COLOR_WHITE, COLOR_BLACK)
      init_pair(PAIR_MOVABLE,  COLOR_WHITE, COLOR_GREEN)
      init_pair(PAIR_SELECTED, COLOR_WHITE, COLOR_RED)
      init_pair(PAIR_AXIS,     COLOR_BLUE,  COLOR_BLACK)
      init_pair(PAIR_INFO,     COLOR_WHITE, COLOR_BLACK)
    end

    def select
      case Curses.getch
        when Curses::Key::RIGHT, 'l'
          if disc = @board.selected.offset(1,0)
            @board.selected = disc
          end
        when Curses::Key::LEFT, 'h'
          if disc = @board.selected.offset(-1,0)
            @board.selected = disc
          end
        when Curses::Key::UP, 'k'
          if disc = @board.selected.offset(0,-1)
            @board.selected = disc
          end
        when Curses::Key::DOWN, 'j'
          if disc = @board.selected.offset(0,1)
            @board.selected = disc
          end
        when Curses::Key::ENTER, ' ', 10
          return true
      end
      return false
    end


    def draw(movable = true)
      line = 0
      clear

      # x axis
      attrset(color_pair(PAIR_AXIS))
      setpos(line+=1, 0)
      addstr("  " + (0..(@board.width-1)).map{|n| n < 10 ? " #{n}" : n}.join())

      # board
      setpos(++line, 0)
      @board.discs.each_with_index do |discs, y|
        setpos(line += 1, 0)
        attrset(color_pair(PAIR_AXIS))
        addstr(y.to_s)
        discs.each_with_index do |d, x|
          setpos(line, 2+x)
          if @board.selected && @board.selected.x == x && @board.selected.y == y
            attrset(color_pair(PAIR_SELECTED))
            addstr(d.to_s)
          elsif movable && d.movable?(@board.player)
            attrset(color_pair(PAIR_MOVABLE))
            addstr(Disc::SPACE_ICON)
          else 
            attrset(color_pair(PAIR_DISC))
            addstr(d.to_s)
          end
        end
        setpos(line, 2+discs.size)
        attrset(color_pair(PAIR_AXIS))
        addstr(" "+y.to_s)
      end

      # x axis
      setpos(line+=1, 0)
      attrset(color_pair(PAIR_AXIS))
      addstr("  " + (0..(@board.width-1)).map{|n| n < 10 ? " #{n}" : n}.join())

      # score
      attrset(color_pair(PAIR_INFO))
      setpos(line += 2, 1)
      addstr "Score : %s%0d, %s%0d" % [Disc::WHITE_ICON, @board.scores[Disc::WHITE], Disc::BLACK_ICON, @board.scores[Disc::BLACK]]
      setpos(line += 1, 1)
      addstr "Player: %s" % [Disc.icon(@board.player)]
      setpos(line += 1, 1)
      addstr "Selected: [%d, %d]" % [@board.selected.x, @board.selected.y]

      #logs
      @board.logs.each do |log| 
        setpos(line += 1, 1)
        addstr log
      end

      refresh
    end
  end
end
