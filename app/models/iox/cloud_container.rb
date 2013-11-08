require('fileutils')

module Iox

  class CloudContainer < ActiveRecord::Base

    acts_as_iox_cloud_container
    has_many :privileges

  end
end
