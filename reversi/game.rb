module Reversi
  class Game
    include Reversi::Logger
    attr_reader :board, :canvas, :players, :history

    def run(options = {})
      options = {
        :interval => 0.15, :size => 8, :white => :random, :black => :minimax
      }.merge(options)
      @board = Board.new(options).reset!
      @canvas = Canvas.new(options)
      @players = {
        Disc::WHITE => Player.instance(Disc::WHITE, self, options[:white]),
        Disc::BLACK => Player.instance(Disc::BLACK, self, options[:black])
      }
      @board.canvas = @canvas
      @canvas.draw(@board)
      @history = []
      while (!@board.over?)
        begin
          @history << @board.dup
          @board.selected = @players[@board.player].select(@board)
        rescue UndoException
          if @history.size >= 3
            @board = @history.slice!(-3..-1)[0]
            @board.selected = @board.get(0, 0)
            @board.logs << "Undo"
          end
          @canvas.draw(@board)
          retry
        end
        @board.move(@board.selected, @board.player)
        @canvas.draw(@board, {:movable => @players[@board.player].human?})
        sleep options[:interval] if options[:interval] > 0
      end
      @board.logs << "GAME OVER. #{@canvas.scores(@board)}."
      @canvas.draw(@board)
    end
  end
end
