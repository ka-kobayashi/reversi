module Reversi
  class Game
    attr_reader :board, :canvas, :players

    def run(options = {})
      options = {
        :interval => 0.15, :size => 8, :white => :random, :black => :minimax
      }.merge(options)
      @board = Board.new(options).reset!
      @canvas = Canvas.new(@board, options)
      @players = {
        Disc::WHITE => Player.instance(Disc::WHITE, self, options[:white]),
        Disc::BLACK => Player.instance(Disc::BLACK, self, options[:black])
      }
      @board.canvas = @canvas
      @canvas.draw
      while (!@board.over?)
        @board.selected = @players[@board.player].select(@board)
        @board.move(@board.selected, @board.player)
        @canvas.draw(@players[@board.player].human?)
        sleep options[:interval] if options[:interval] > 0
      end
      @board.logs << "GAME OVER. #{@canvas.scores}."
      @canvas.draw
    end
  end
end
