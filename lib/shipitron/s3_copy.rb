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
          fail_with_error!(message: 'Failed to transfer to/from s3 (mocked).')
        end
      else
        Logger.info "S3 Copy from #{source} to #{destination}"
        Logger.info `curl ${ECS_CONTAINER_METADATA_URI_V4}/task`
        Logger.info `docker run --rm -t -v shipitron-home:/home/shipitron -e AWS_CONTAINER_CREDENTIALS_RELATIVE_URI amazon/aws-cli:latest --region #{region} s3 cp #{source} #{destination} --quiet --only-show-errors`
        if $? != 0
          fail_with_error!(message: 'Failed to transfer to/from s3.')
        end

        Logger.info "S3 result: #{Pathname.new(destination).parent.children.inspect}"
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
