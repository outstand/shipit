require 'mustache'
require 'yaml'

module Shipitron
  class MustacheYamlParser
    def initialize(file_path, options = {})
      @context = options[:context]
      @view = options[:view]

      if (@context.nil? && @view.nil?) || (!@context.nil? && !@view.nil?)
        raise ArgumentError, 'Either context or view required'
      end

      @file_path = file_path.is_a?(Pathname) ? file_path.to_s : file_path
      @view ||= Mustache
    end

    def perform
      YAML.load(@view.render(File.read(@file_path), @context))
    end

    def self.perform(file_path, options = {})
      new(file_path, options).perform
    end
  end
end
