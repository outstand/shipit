require 'mustache'
require 'yaml'

module Shipitron
  class MustacheYamlParser
    def initialize(context:nil, view:nil)
      if (context.nil? && view.nil?) || (!context.nil? && !view.nil?)
        raise ArgumentError, 'Either context or view required'
      end

      @context = context
      @view = view

      @view ||= Mustache
    end

    def perform(file_path)
      file_path = file_path.is_a?(Pathname) ? file_path.to_s : file_path
      YAML.load(@view.render(File.read(file_path), @context))
    end
  end
end
