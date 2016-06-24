require 'shipitron'

module Shipitron
  class EcsTask < Hashie::Dash
    property :name
    property :revision

    def name_with_revision
      "#{name}:#{revision}"
    end

    def to_s
      name_with_revision
    end
  end
end
