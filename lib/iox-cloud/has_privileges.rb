# encoding: utf-8
require 'digest/sha2'

module Iox
  module ActsAsCloudContainer

    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def has_iox_privileges(options = {})

        include InstanceMethods

        has_many :privileges, dependent: :delete_all

      end
    end

    module InstanceMethods

      # a user has privileges on the document
      # if a privilege entry exists
      # 
      # @param user [User] the user object to be checked for access
      #
      # @return [Boolean] true
      def can_read?(user)
        return true if user.is_admin?
        return privileges.where(user_id: user).count > 0
      end

      # a user can write, if can_write attribute
      # is set to true
      # 
      # @param user [User] the user object to be checked for access
      #
      # @return [Boolean] true
      def can_write?(user)
        return true if user.is_admin?
        priv = privileges.where(user_id: user).first
        return false unless priv
        return priv.can_write?
      end

      # a user can delete, if can_delete attribute
      # is set to true
      # 
      # @param user [User] the user object to be checked for access
      #
      # @return [Boolean] true
      def can_delete?(user)
        return true if user.is_admin?
        priv = privileges.where(user_id: user).first
        return false unless priv
        return priv.can_delete?
      end

      # a user can share, if can_share attribute
      # is set to true
      # 
      # @param user [User] the user object to be checked for access
      #
      # @return [Boolean] true
      def can_share?(user)
        return true if user.is_admin?
        priv = privileges.where(user_id: user).first
        return false unless priv
        return priv.can_share?
      end

    end

  end
end

ActiveRecord::Base.send :include, Iox::ActsAsCloudContainer