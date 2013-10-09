module Reversi
  class Game
    attr_reader :board, :canvas, :player

    def run(options = {})
      options = {
        :interval => 0.2, :width => 8, :height => 8, 
        :white => :random, :black => :random
      }.merge(options)
      @players = {
        Disc::WHITE => Reversi::Player.instance(options[:white]),
        Disc::BLACK => Reversi::Player.instance(options[:black])
      }
      @board = Reversi::Board.new(options)
      @canvas = Reversi::Canvas.new(@board, options)
      @board.canvas = @canvas
      @canvas.draw
      while (!@board.over?)
        if @players[@board.player].human?
          while (!(@canvas.select && @board.movable?(@board.selected.x, @board.selected.y, @board.player)))
            @canvas.draw
          end
        else
          @board.selected = @players[@board.player].select(@board.clone)
        end
        @board.move(@board.selected.x, @board.selected.y, @board.player)
        if @board.pass?
          @board.next_player! 
        end
        @canvas.draw
      end
    end
  end
end
