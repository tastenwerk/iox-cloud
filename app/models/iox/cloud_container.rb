require('fileutils')

module Iox

  class CloudContainer < ActiveRecord::Base

    class << self

      # return the configured cloud path
      # this should be configured in you application.rb file
      # as config.iox.cloud_storage_path = 'path/to/file'
      #
      # relative or absolute path definition is possible
      #
      # raises Iox::Cloud::InvlaidPath if path cannot be created
      #
      def get_cloud_storage_path
        path = ""
        if Rails.configuration.iox.cloud_storage_path
          if Rails.configuration.iox.cloud_storage_path[0,1] == '/'
            path = Rails.configuration.iox.cloud_storage_path
          else
            path = File::join( Rails.root, Rails.configuration.iox.cloud_storage_path )
          end
        end

        raise Iox::Cloud::InvalidPathError.new("no path given in application.rb (config.iox.cloud_storage_path needs to be set") if path.blank?

        path = File::absolute_path( path )
        FileUtils::mkdir_p( path ) unless File::exists?( path )
        path
      rescue Errno::EACCES
        raise Iox::Cloud::InvalidPathError.new("path #{path} is not valid or cannot be created (permissions?) check application.rb")
      end

    end

    acts_as_iox_cloud_container

    has_many :privileges

  end
end
