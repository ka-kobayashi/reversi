# -*- coding: utf-8 -*-
require 'logger'

class Logger
  def trace(message)
    prefix = caller.first
    prefix[REVERSI_DIR+"/"] = ''
    prefix.sub!(/in \`block \(\d+ levels\) in reverse\'/, ' ')
    debug("#{prefix}#{message}")
  end
end

module Reversi
  module Logger
    @@instance = nil

    def logger(file = '/tmp/reversi.log', level = ::Logger::DEBUG)
      if @@instance.instance_of?(Logger)
        return @@instance
      end

      @@instance = ::Logger.new(file)
      @@instance.level = level
      @@instance.formatter = proc{|severity, datetime, progname, message|
        "["+datetime.strftime("%Y-%m-%d %H:%M:%S")+"][#{severity[0..0]}] #{message}\n"
      }
      return @@instance
    end

    module_function :logger
  end
end
