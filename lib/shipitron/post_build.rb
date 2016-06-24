require 'shipitron'

module Shipitron
  class PostBuild < Hashie::Dash
    property :ecs_task
    property :container_name
    property :command

    # String is of the format:
    # 'ecs_task:task,container_name:name,command:command
    def self.parse(str)
      PostBuild.new.tap do |post_build|
        str.split(',').each do |part|
          part.match(/([^:]+):(.+)/) do |m|
            prop = m[1].to_sym
            if property?(prop)
              post_build[prop] = m[2]
            end
          end
        end

        properties.each do |prop|
          raise "post build argument missing '#{prop}'" if post_build[prop].nil?
        end
      end
    end

    def to_s
      "ecs_task:#{ecs_task},container_name:#{container_name},command:#{command}"
    end
  end
end
