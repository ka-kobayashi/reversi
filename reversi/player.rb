module Reversi
  module Player
    def self.instance game, name, options={}
      name = "human" unless name || name == ""
      require "#{File.dirname(__FILE__)}/player/#{name}.rb"
      Reversi::Player.const_get(name.to_s.capitalize).new(game, name, options)
    end

    class Base
      attr_reader :game, :name, :options, :default_recursive

      def initialize(game, name, options)
        @game = game
        @name = name
        @options = options
        @default_recursive = 0
        configure
      end

      def configure
      end

      def human?
        @name == "human"
      end

      def trace(message)
        @game.board.logs << message
      end

      def select(board)
        board = board.dup
        board.canvas = nil
        result = lookup(board.player, board)
        trace "%s: [%s] (%d, %d) => %d" % [Reversi::Disc.icon(board.player), @name, result[0].x, result[0].y, result[1]]
        result[0]
      end

      def lookup(player, board, options = {})
        options = {:recursive => @default_recursive}.merge(options)

        plans = {}
        board.movable.each do |d|
          b = board.dup
          b.move(d.x, d.y, b.player)
          plans[d] = evaluate(b, d.x, d.y, board.player, options)
          if options[:recursive] > 0 && !b.over?
            options[:recursive] -= 1
            plans[d] += (board.player == player ? 1 : -1) * lookup(player, b, options)[1]
          end
        end
        return [nil, 0] if plans.size < 1

        disc = plans.max{|a,b| a[1] <=> b[1]}[0]
        return [disc, plans[disc]]
      end

      def evaluate(board, x, y, player, options = {})
        0
      end
    end
  end
end
