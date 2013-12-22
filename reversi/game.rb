module Reversi
  class Game
    attr_reader :board

    def run(options = {})
      options = {:width => 8, :height => 8}.merge(options)
      @board = Reversi::Board.new(options)
      @board.canvas.draw
      while (!@board.over?)
        while (true)
          pos = @board.canvas.gets
          break if @board.movable?(pos[0], pos[1], @board.player)
        end
        @board.move(pos[0], pos[1], @board.player)
        @board.next_player! 
        if @board.pass?
          @board.next_player! 
        end
        @board.canvas.draw
      end
    end
  end
end
