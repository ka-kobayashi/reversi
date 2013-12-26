module Reversi
  class Game
    attr_reader :board, :canvas, :player

    def run(options = {})
      options = {
        :interval => 0.2, :width => 8, :height => 8, 
        :white => :random, :black => :minimax
      }.merge(options)
      @players = {
        Disc::WHITE => Reversi::Player.instance(self, options[:white]),
        Disc::BLACK => Reversi::Player.instance(self, options[:black])
      }
      @board = Reversi::Board.new(options)
      @canvas = Reversi::Canvas.new(@board, options)
      @board.canvas = @canvas
      @canvas.draw
      while (!@board.over?)
        @board.selected = @players[@board.player].select(@board)
        @board.move(@board.selected.x, @board.selected.y, @board.player)
        @canvas.draw(@players[@board.player].human?)
        sleep options[:interval] if options[:interval] > 0
      end
      @board.logs << "GAME OVER. #{@canvas.scores}."
      @canvas.draw
    end
  end
end
