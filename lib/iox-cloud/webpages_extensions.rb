module Iox
  module Cloud
    module WebpagesExtensions


      extend ActiveSupport::Concern

      included do
        cloud_container_defaults
      end

      module ClassMethods
        def cloud_container_defaults
          belongs_to :cloud_container
          Rails.configuration.iox.allowed_webpage_attrs << :cloud_container_id
        end
      end

    end
  end
end