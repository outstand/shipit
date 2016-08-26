require 'hashie'
require 'shipitron/application'

module Shipitron
  class Config < Hashie::Dash
    include Hashie::Extensions::Dash::Coercion

    property :s3_bucket
    property :applications, coerce: Hash[String => Application]
    property :pre_launch
    property :launch

    def initialize_copy(other)
      super
      self.applications = self.applications.each_with_object({}) {|(k,v),hash| hash[k] = v.dup }
      # TODO: dup pre_launch
      # TODO: dup launch
    end

    def to_yaml
      to_hash.tap do |config|
        config[:applications] = config[:applications].each_with_object({}) {|(k,v),hash| hash[k] = v.to_hash }
      end.to_yaml
    end
  end
end
