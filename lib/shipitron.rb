require 'shipitron/version'
require 'hashie'
require 'shipitron/logger'
require 'metaractor'
require 'shipitron/smash'

module Shipitron
  CONFIG_FILE = 'shipitron/config.yml'.freeze
  SECRETS_FILE = 'shipitron/secrets.yml'.freeze

  class << self
    def config_file
      @config_file ||= CONFIG_FILE
    end

    def config_file=(file)
      @config_file = file
    end

    def config
      @config ||= Smash.load(config_file).merge(secrets)
    rescue ArgumentError
      Logger.warn "Config file '#{config_file}' does not exist"
      @config = secrets
    end

    def secrets_file
      @secrets_file ||= SECRETS_FILE
    end

    def secrets_file=(file)
      @secrets_file = file
    end

    def secrets
      @secrets ||= Smash.load(secrets_file)
    rescue ArgumentError
      Logger.warn "Secrets file '#{secrets_file}' does not exist"
      @secrets = Smash.new
    end
  end
end
