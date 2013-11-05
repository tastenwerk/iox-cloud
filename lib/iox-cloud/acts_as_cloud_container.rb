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
        has_iox_privileges

        attr_accessor :user

        before_validation :gen_public_key, on: :create
        after_create :git_init_bare

        validates :name, presence: true
        validates :public_key, presence: true, uniqueness: true

      end
    end

    module InstanceMethods

      # list documents inside this
      # cloud container
      #
      # @param type [Symbol] `:all` (default), `:files` or `:folders`
      #
      def list( type = :all )
        type = :tree if type == :folders
        type = :blob if type == :files
        git_init unless @repo
        head = @repo.lookup( @repo.head.target )
        head.tree.inject([]) do |arr,obj|
          arr << obj if type == :all || obj[:type] == type
          arr
        end
      end

      # looks up for the given oid and returns
      # a file object if any
      #
      # @param oid [String] the object_id in the git repository
      def get_file( oid )
        git_init unless @repo
        if obj = @repo.lookup( oid )
          return obj.read_raw.data if obj.type == :blob
        end
      end

      # adds a file object to the repository
      #
      # @param file [File] the file to be added
      # @param message [String] a commit message (optional)
      #
      def add_file( file, message = "added file" )
        git_init unless @repo
        raise TypeError.new('given file must be of type File') unless file.is_a?(File)
        oid = @repo.write( file.read, :blob )
        @repo.index.add(:path => File::basename(file.path), :oid => oid, :mode => 0100644)
        options = { message: message }
        options[:tree] = @repo.index.write_tree(@repo)
        options[:author] = user_opts
        options[:committer] = user_opts
        options[:parents] = @repo.empty? ? [] : [ @repo.head.target ].compact
        options[:update_ref] = 'HEAD'
        Rugged::Commit.create(@repo, options)
      end

      # adds a folder object to the repository
      #
      # @param name [String] the folder name to be added
      # @param message [String] a commit message (optional)
      #
      def add_folder( name, message = "added folder" )
        git_init unless @repo
        oid = @repo.write("You can delete this file", :blob)
        @repo.index.add(:path => "#{name}/_empty_folder", :oid => oid, :mode => 0100644)
        options = { message: message }
        options[:tree] = @repo.index.write_tree(@repo)
        options[:author] = user_opts
        options[:committer] = user_opts
        options[:parents] = @repo.empty? ? [] : [ @repo.head.target ].compact
        options[:update_ref] = 'HEAD'
        Rugged::Commit.create(@repo, options)
      end

      def set_creator_and_updater( user )
        if new_record?
          self.creator = user
        end
        self.updater = user
      end

      def gen_public_key
        o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
        self.public_key = (0..8).map{ o[rand(o.length)] }.join
        if self.class.where( public_key: public_key ).count > 0
          @gen_public_key_trials ||= 0
          @gen_public_key_trials += 1
          gen_public_key
        end
      end

      def git_init_bare
        git_init( :bare )
      end

      # initializes this cloud container's git repository
      #
      def git_init( bare=nil )
        raise Iox::Cloud::InvalidUserError unless user
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
        path = "#{Iox::CloudContainer.storage_path}/#{self.class.name.demodulize.underscore}/#{public_key}"
        FileUtils::mkdir_p( path ) unless File::exists?( path )
        path
      end

      def create_plain_repos
        @repo = Rugged::Repository.init_at storage_path, :bare
        oid = @repo.write("This is an ioX cloud repository\nYou can delete this file\n", :blob)
        @repo.index.add(:path => "_ioX-cloud-repository", :oid => oid, :mode => 0100644)
        options = {}
        options[:tree] = @repo.index.write_tree(@repo)
        options[:author] = user_opts
        options[:committer] = user_opts
        options[:message] ||= "Initial repository commit"
        options[:parents] = []
        options[:update_ref] = 'HEAD'
        Rugged::Commit.create(@repo, options)
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