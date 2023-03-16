require 'shipitron'
require 'diplomat'

module Shipitron
  module ConsulKeys
    extend self

    def fetch_key(key:)
      Logger.debug "Fetching key #{key}"
      value = Diplomat::Kv.get(key, {}, :return)
      value = nil if value == ''
      value
    end

    def fetch_key!(key:)
      fetch_key(key: key).tap do |value|
        if value.nil?
          raise "Key #{key} not found in consul!"
        end
      end
    end

    def set_key(key:, value:)
      Logger.debug "Setting key #{key}"
      Diplomat::Kv.put(key, value)
    end

    def set_key!(key:, value:)
      set_key(key: key, value: value).tap do |retval|
        raise "Unable to set #{key}!" if retval != true
      end
    end

  end
end
