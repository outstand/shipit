require 'shipitron/version'
require 'hashie'

module Shipitron
  CONFIG_FILE = 'config/shipitron.yml'.freeze

  class << self
    def config
      @config ||= Hashie::Mash.load(CONFIG_FILE)
    end
  end
end
