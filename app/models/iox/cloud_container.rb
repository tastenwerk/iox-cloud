require('fileutils')

module Iox

  class CloudContainer < ActiveRecord::Base

    acts_as_iox_cloud_container
    has_accessible_links
    has_privileges

    has_one :webpage, class_name: 'Iox::Webpage'

  end
end
