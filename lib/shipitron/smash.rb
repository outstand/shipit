require 'hashie'

module Shipitron
  class Smash < Hashie::Mash
    private
    def convert_key(key)
      key.to_sym
    end
  end
end
