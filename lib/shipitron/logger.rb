require 'logger'

module Shipitron
  class Logger
    class << self
      %i[debug info warn error fatal].each do |sym|
        define_method(sym) do |message|
          logger.send(sym, "#{Thread.current[:logger_tag]}#{message}")
        end
      end
    end

    def self.tagged(tag)
      existing_tag = Thread.current[:logger_tag]
      Thread.current[:logger_tag] = "[#{tag}] "
      yield
    ensure
      Thread.current[:logger_tag] = existing_tag
    end

    def self.logger
      Thread.current[:logger] ||= ::Logger.new(STDOUT)
    end

    def self.level
      logger.level
    end

    def self.level=(new_level)
      logger.level = new_level
    end
  end
end
