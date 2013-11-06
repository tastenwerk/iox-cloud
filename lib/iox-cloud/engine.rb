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
        )
      end

      if defined?( ActiveRecord )
        ActiveRecord::Base.send( :include, IoxCloud::Schema )
      end

      initializer :append_migrations do |app|
        unless app.root.to_s.match root.to_s
          config.paths["db/migrate"].expanded.each do |expanded_path|
            app.config.paths["db/migrate"] << expanded_path
          end
        end
      end

    end

  end
end
