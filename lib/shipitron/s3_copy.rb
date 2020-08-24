require 'shipitron'

module Shipitron
  class S3Copy
    include Metaractor

    required :source
    required :destination
    required :region

    def call
      if ENV['FOG_LOCAL']
        Logger.info `cp #{source.gsub('s3://', '/fog/')} #{destination.gsub('s3://', '/fog/')}`
        if $? != 0
          fail_with_error!('Failed to transfer to/from s3 (mocked).')
        end
      else
        # TODO: Deal with docker mounting from the host but we're in a container already
        Logger.info `docker run --rm -it amazon/aws-cli:latest --region #{region} s3 cp #{source} #{destination}`
        if $? != 0
          fail_with_error!('Failed to transfer to/from s3.')
        end
      end
    end

    private
    def source
      context.source
    end

    def destination
      context.destination
    end

    def region
      context.region
    end
  end
end
