require 'logger'

module Reversi
  module Logger
    @@instance = nil

    def logger(file = '/tmp/reversi.log')
      unless @@instance
        @@instance = ::Logger.new(file)
      end
      @@instance
    end

    module_function :logger

  end
end
