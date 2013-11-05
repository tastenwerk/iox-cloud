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

      def git_init( bare=nil )
        raise Iox::Cloud::InvalidUserError unless user
        options = { author: {
          email: user.email, 
          name: user.full_name, 
          time: Time.now }
        }
        if bare == :bare
          @repos = Rugged::Repository.init_at get_cloud_storage_path, :bare
        else
          @repos = Rugged::Repository.new get_cloud_storage_path
        end
      end

      def get_cloud_storage_path
        path = "#{Iox::CloudContainer.get_cloud_storage_path}/#{self.class.name.demodulize.underscore}/#{public_key}"
        FileUtils::mkdir_p( path ) unless File::exists?( path )
        path
      end

      def get_repos_db_path
        File::join get_cloud_storage_path, "#{public_key}_db"
      end

      def get_repos_clone_path
        File::join get_cloud_storage_path, "#{public_key}_clone"
      end

    end

  end
end

ActiveRecord::Base.send :include, Iox::ActsAsCloudContainer