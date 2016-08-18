require 'shipitron'
require 'yaml'
require 'mustache'

module Shipitron
  module Server
    class ParseTemplates
      include Metaractor

      required :templates
      required :template_context

      def call
        parsed = []
        templates.each do |template|
          parsed << Smash.new(YAML.load(Mustache.render(template, template_context)))
        end

        context.parsed_templates = parsed
      end

      private
      def templates
        context.templates
      end

      def template_context
        context.template_context
      end
    end
  end
end
