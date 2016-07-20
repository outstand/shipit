require 'shipitron'

module Shipitron
  class DockerImage < Hashie::Dash
    property :name
    property :tag

    def name_with_tag(tag_override = nil)
      tag_str = [tag, tag_override, ''].first {|str| !str.nil? }
      tag_str = tag_str.to_s

      if !tag_str.empty? && !tag_str.start_with?(':')
        tag_str.prepend(':')
      end

      "#{image_name}#{tag_str}"
    end

    def to_s
      name_with_tag
    end
  end
end
