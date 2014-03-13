# -*- coding: utf-8 -*-
module Reversi
  class Game
    include Reversi::Logger
    attr_reader :board, :canvas, :players, :history

    def load(filename)
      if data = File.open(filename).read
        return Marshal.load(data)
      end
      nil
    end

    def save(board, filename = nil)
      filename = "%s/data/%s.dat" % [REVERSI_DIR, Time.now.to_i]
      file = File.open(filename, 'w+')
      file.puts Marshal.dump(board)
      file.close
      filename
    end

    def run(options = {})
      options = {
        :interval => 0.1, :size => 8, :load => nil, :timeout => 5, :match => 3,
        :white => :random, :black => :minimax
      }.merge(options)

      score = {Disc::WHITE => 0, Disc::BLACK => 0}
      while true do
        winner = match(options)
        sleep 1

        if winner
          p score
          score[winner] += 1
          break if options[:match] == score[winner]
        end
      end

      puts "\n\n"
      if score[Disc::WHITE] == score[Disc::BLACK]
        puts "DRAW - White : Black = %s : %s" % [score[Disc::WHITE], score[Disc::BLACK]]
      elsif score[Disc::WHITE] > score[Disc::BLACK]
        puts "Winner is WHITE - White : Black = %s : %s" % [score[Disc::WHITE], score[Disc::BLACK]]
      else 
        puts "Winner is BLACK - White : Black = %s : %s" % [score[Disc::WHITE], score[Disc::BLACK]]
      end
    end

    def match(options) 
      if options[:load] 
        @board = load(options[:load])
        options[:size] = @board.size
      else
        @board = Board.new(options).reset!
      end
      @players = {
        Disc::WHITE => Player.instance(Disc::WHITE, self, options[:white]),
        Disc::BLACK => Player.instance(Disc::BLACK, self, options[:black])
      }
      @canvas = Canvas.new(options)
      @board.canvas = @canvas
      @canvas.draw(@board)
      @history = []
      while (!@board.over?)
        begin
          @history << @board.dup
          @board.selected = @players[@board.player].select(@board, options[:timeout])
        rescue UndoException
          if @history.size >= 3
            @board = @history.slice!(-3..-1)[0]
            @board.selected = @board.get(0, 0)
            @board.logs << "Undo"
          end
          @canvas.draw(@board)
          retry
        rescue SaveException
          @board.logs << "Saved: #{save(@board)}"
          @canvas.draw(@board)
          retry
        end
        @board.move(@board.selected, @board.player)
        @canvas.draw(@board, {:movable => @players[@board.player].human?})
        sleep options[:interval] if options[:interval] > 0
      end
      @board.logs << "GAME OVER. #{@canvas.scores(@board)}."
      @canvas.draw(@board)

      return @board.winner
    end
  end
end
