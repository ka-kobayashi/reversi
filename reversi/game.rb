module Reversi
  class Game
    attr_reader :board

    def run(options = {})
      options = {:width => 8, :height => 8}.merge(options)
      @board = Reversi::Board.new(options)
      @board.canvas.draw
      while (!@board.over?)
        while (!(@board.canvas.select && @board.movable?(@board.selected.x, @board.selected.y, @board.player)))
          @board.canvas.draw
        end
        @board.move(@board.selected.x, @board.selected.y, @board.player)
        @board.next_player! 
        if @board.pass?
          @board.next_player! 
        end
        @board.canvas.draw
      end
    end
  end
end
