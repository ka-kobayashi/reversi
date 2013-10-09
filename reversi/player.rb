module Reversi
  module Player
    def self.instance name, options={}
      if name
        require "#{File.dirname(__FILE__)}/player/#{name}.rb"
        Reversi::Player.const_get(name.to_s.capitalize).new(name, options)
      else
        Reversi::Player::Base.new(name, options) unless name
      end
    end

    class Base
      attr_reader :name, :board, :options

      def initialize(name, options)
        @name = name
        @options = options
      end

      def human?
        @name == nil
      end

      def selectable(board, player = nil)
        player = board.player unless player
        discs = []
        board.discs.each do |line|
          line.each do |disc|
            discs << disc if disc.movable?(player)
          end
        end
        discs
      end

      def select(board)
        raise 'override me'
      end
    end
  end
end
