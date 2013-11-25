module Iox

  module Cal
    class Event < ActiveRecord::Base

      acts_as_iox_cloud_container

      has_many    :labeled_items, dependent: :destroy
      has_many    :labels, as: :labelabel, through: :labeled_items


    end

  end
end
