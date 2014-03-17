# -*- coding: utf-8 -*-
require "curses"

module Reversi
  class UndoException  < Exception; end
  class SaveException  < Exception; end

  class Canvas
    include Curses
    attr_accessor :options

    PAIR_DISC = 0
    PAIR_MOVABLE = 1
    PAIR_FIXED   = 2
    PAIR_SELECTED = 3 
    PAIR_AXIS = 4
    PAIR_INFO = 5

    def initialize(options)
      @options = {:interval => 0.5}.merge(options)
      
      init_screen
      stdscr.keypad true
      start_color
      init_pair(PAIR_DISC,     COLOR_WHITE, COLOR_BLACK)
      init_pair(PAIR_MOVABLE,  COLOR_WHITE, COLOR_GREEN)
      init_pair(PAIR_FIXED,    COLOR_WHITE, COLOR_BLUE)
      init_pair(PAIR_SELECTED, COLOR_WHITE, COLOR_RED)
      init_pair(PAIR_AXIS,     COLOR_BLUE,  COLOR_BLACK)
      init_pair(PAIR_INFO,     COLOR_WHITE, COLOR_BLACK)
    end

    def select(board)
      case Curses.getch
        when Curses::Key::RIGHT, 'l'
          if disc = board.selected.offset(1,0)
            board.selected = disc
          end
        when Curses::Key::LEFT, 'h'
          if disc = board.selected.offset(-1,0)
            board.selected = disc
          end
        when Curses::Key::UP, 'k'
          if disc = board.selected.offset(0,-1)
            board.selected = disc
          end
        when Curses::Key::DOWN, 'j'
          if disc = board.selected.offset(0,1)
            board.selected = disc
          end
        when Curses::Key::ENTER, ' ', 10
          return false if board.selected.space?
        when 'u', 27 # ESC
          raise UndoException
        when 's'
          raise SaveException
      end
      return true
    end

    def moved(board)
      draw(board, {:movable => false})
    end

    def reversed(board)
      draw(board, {:movable => false})
      sleep @options[:interval] if @options[:interval] > 0
    end

    def draw(board, options = {})
      options = {:movable => true, :fixed => true}.merge(options)
      line = 0
      clear

      # x axis
      attrset(color_pair(PAIR_AXIS))
      setpos(line+=1, 0)
      addstr("  " + (0..(board.size-1)).map{|n| " #{n}"}.join())

      # board
      setpos(++line, 0)
      board.discs.each do |d|
        if (d.x == 0) 
          setpos(line += 1, 0)
          attrset(color_pair(PAIR_AXIS))
          addstr(d.y.to_s)
        end

        setpos(line, d.x + 2)
        if board.selected && board.selected.x == d.x && board.selected.y == d.y
          attrset(color_pair(PAIR_SELECTED))
        elsif options[:movable] && d.movable?(board.player)
          attrset(color_pair(PAIR_MOVABLE))
        elsif options[:fixed] && board.fixed?(d)
          attrset(color_pair(PAIR_FIXED))
        else 
          attrset(color_pair(PAIR_DISC))
        end
        addstr(d.to_s)

        if (d.x == board.size - 1) 
          setpos(line, board.size + 2)
          attrset(color_pair(PAIR_AXIS))
          addstr(" "+d.y.to_s)
        end
      end

      # x axis
      setpos(line+=1, 0)
      attrset(color_pair(PAIR_AXIS))
      addstr("  " + (0..(board.size-1)).map{|n| " #{n}"}.join())

      # score
      attrset(color_pair(PAIR_INFO))
      setpos(line += 2, 1)
      addstr "Player: %s%s %s%s" % [Disc.icon(Disc::WHITE), @options[:white], Disc.icon(Disc::BLACK), @options[:black]]
      setpos(line += 1, 1)
      addstr "Score : %s  Turn: %s" % [scores(board), Disc.icon(board.player)]
      setpos(line += 1, 1)
      addstr "Selected: [%d, %d]" % [board.selected.x, board.selected.y] if board.selected

      #logs
      board.logs.last(10).each do |log| 
        setpos(line += 1, 1)
        addstr log
      end
      addstr "\n"

      refresh
    end

    def scores(board)
      "%s%0d, %s%0d" % [Disc::WHITE_ICON, board.scores[Disc::WHITE], Disc::BLACK_ICON, board.scores[Disc::BLACK]]
    end
  end
end
