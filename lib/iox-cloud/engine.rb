require 'iox/engine'

module Iox
  module Cloud

    class Engine < ::Rails::Engine

      isolate_namespace Iox

      config.generators do |g|
        g.test_framework :rspec, :fixture => false
        g.assets false
        g.helper false
      end

      initializer :assets do |config|
        Rails.application.config.assets.precompile << %w(
          iox/cloud/cloud_containers.js
          iox/cloud/cloud_containers.css
        )
      end

      if defined?( ActiveRecord )
        ActiveRecord::Base.send( :include, Iox::Cloud::Schema )
      end

      initializer :extend_webpage, after: :bootstrap_hook do |app|
        Iox::Webpage::send( :include, Iox::Cloud::WebpagesExtensions )
      end

      initializer :append_migrations do |app|
        #unless app.root.to_s.match root.to_s
          config.paths["db/migrate"].expanded.each do |expanded_path|
            app.config.paths["db/migrate"] << expanded_path
          end
        #end
      end

    end

  end
end
