require 'shipitron'

module Shipitron
  module Client
    def self.started_by
      ENV.fetch("SHIPITRON_STARTED_BY", "shipitron")
    end
  end
end
