# encoding: utf-8
require 'rugged'
require 'fileutils'

module Iox
  module ActsAsCloudContainer

    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods

      def acts_as_iox_cloud_container(options = {})

        include InstanceMethods
        extend ClassMethods

        attr_accessor :user

        belongs_to :creator, class_name: 'Iox::User', foreign_key: :created_by
        belongs_to :updater, class_name: 'Iox::User', foreign_key: :updated_by

        before_create :set_creator_and_updater

        before_destroy :cleanup_repos

        after_create :git_init_bare
        validates :name, presence: true
        validates :user, presence: true

      end

    end

    module ClassMethods

      # return the configured cloud path
      # this should be configured in you application.rb file
      # as config.iox.cloud_storage_path = 'path/to/file'
      #
      # relative or absolute path definition is possible
      #
      # raises Iox::Cloud::InvlaidPath if path cannot be created
      #
      def storage_path
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

    module InstanceMethods

      # list documents inside this
      # cloud container
      #
      # @param path [String] - the directory to list the files for. Default: '.'
      #
      def list( path = '.' )
        git_init unless @repo
        @repo.index.reload
        folders = []
        @repo.index.entries.inject([]) do |arr, ientry|
          if File::dirname( ientry[:path] ) == path
            arr << CloudFile.new( ientry, user, @repo )
          elsif !folders.include?( File::dirname( ientry[:path] ) ) &&
                ientry[:path].include?( '/' )
            arr << CloudDirectory.new( ientry, user, @repo, self )
            folders << File::dirname( ientry[:path] )
          end
          arr
        end
      end

      # looks up for the given path name and returns
      # a file object if any
      #
      # @param path [String] the path the git repository
      def get_file( path )
        git_init unless @repo
        if @repo.index[path]
          return CloudFile.new( @repo.index[path], user, @repo )
        end
      end

      # looks up for the given oid and returns
      # a file object if any
      #
      # @param path [String] the path the git repository
      def get_directory( path )
        git_init unless @repo
        @repo.index.each do |ientry|
          next unless File::dirname(ientry[:path]) == path
          return CloudDirectory.new( ientry, user, @repo, self )
        end
      end

      # adds a file object to the repository
      #
      # @param name [String] the name this file should be stored under
      # @param directory [String] the directory this file should be added
      # @param data [IOStream] e.g.: #<File>.read
      #
      # @return itself (chainable)
      #
      def add_file( name, directory, data )
        git_init unless @repo
        oid = @repo.write( data, :blob )
        @repo.index.add( path: (directory.blank? || directory.match(/^\/$/) ? name : File::join( directory, name )),
                          oid: oid,
                          mode: 0100644 )
        self
      end

      # adds a folder object to the repository
      #
      # @param name [String] the folder name to be added
      # @return itself (chainable)
      #
      def add_directory( name )
        git_init unless @repo
        oid = @repo.write("", :blob)
        @repo.index.add(:path => "#{name}/.git_keep", :oid => oid, :mode => 0100644)
        self
      end

      # commit pending changes
      #
      # @param message [String] a commit message (optional)
      #
      def commit( message = "auto-message" )
        raise Iox::Cloud::InvalidUserError unless user
        options = { message: message }
        options[:tree] = @repo.index.write_tree(@repo)
        options[:author] = user_opts
        options[:time] = Time.now
        options[:committer] = user_opts
        options[:parents] = @repo.empty? ? [] : [ @repo.head.target ].compact
        options[:update_ref] = 'HEAD'
        Rugged::Commit.create(@repo, options)
        @repo.index.write
      end

      def set_creator_and_updater( user=user )
        if new_record?
          self.creator = user
        end
        self.updater = user
      end

      def git_init_bare
        git_init( :bare )
      end

      # initializes this cloud container's git repository
      #
      def git_init( bare=nil )
        if bare == :bare
          create_plain_repos
        else
          @repo = Rugged::Repository.new storage_path
        end
      end

      # return location of the git repository
      # of this cloud container
      #
      # @return [string] path to this cloud container's git repository
      def storage_path
        path = "#{self.class.storage_path}/#{self.class.name.demodulize.underscore}/#{id}"
        FileUtils::mkdir_p( path ) unless File::exists?( path )
        path
      end

      def create_plain_repos
        raise Iox::Cloud::InvalidUserError unless user
        @repo = Rugged::Repository.init_at storage_path, :bare
        oid = @repo.write("", :blob)
        @repo.index.add(:path => ".git_keep", :oid => oid, :mode => 0100644)
        options = {}
        options[:tree] = @repo.index.write_tree(@repo)
        options[:author] = user_opts
        options[:time] = Time.now
        options[:committer] = user_opts
        options[:message] ||= "Initial repository commit"
        options[:parents] = []
        options[:update_ref] = 'HEAD'
        Rugged::Commit.create(@repo, options)
      end

      def cleanup_repos
        FileUtils::rm_rf storage_path
      end

      # touches a cloud container and
      # updates updated_at and updated_by
      #
      def touch
        self.updated_at = Time.now
        self.updated_by = user.id
      end

      private

      def user_opts
        { email: user.email,
          name: user.full_name,
          time: Time.now }
      end

    end

  end
end

ActiveRecord::Base.send :include, Iox::ActsAsCloudContainer