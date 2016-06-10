require 'diplomat'

module Shipitron
  module ConsulLock
    extend self

    class UnableToLock < StandardError; end

    def with_lock(key:)
      sessionid = nil
      locked = false
      sessionid = Diplomat::Session.create(Name: "#{key}.lock")
      locked = Diplomat::Lock.acquire(key, sessionid)

      if locked
        yield
      else
        raise UnableToLock
      end
    ensure
      if sessionid != nil
        Diplomat::Lock.release(key, sessionid) if locked
        Diplomat::Session.destroy(sessionid)
      end
    end

  end
end
