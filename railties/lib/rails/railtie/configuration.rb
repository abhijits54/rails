require 'rails/configuration'

module Rails
  class Railtie
    class Configuration
      def initialize
        @@options ||= {}
      end

      # This allows you to modify the application's middlewares from Engines.
      #
      # All operations you run on the app_middleware will be replayed on the
      # application once it is defined and the default_middlewares are
      # created
      def app_middleware
        @@app_middleware ||= Rails::Configuration::MiddlewareStackProxy.new
      end

      # This allows you to modify application's generators from Railties.
      #
      # Values set on app_generators will become defaults for application, unless
      # application overwrites them.
      def app_generators
        @@app_generators ||= Rails::Configuration::Generators.new
        yield(@@app_generators) if block_given?
        @@app_generators
      end

      def generators(&block) #:nodoc
        ActiveSupport::Deprecation.warn "config.generators in Rails::Railtie is deprecated. Please use config.app_generators instead."
        app_generators(&block)
      end

      # First configurable block to run. Called before any initializers are run.
      def before_configuration(&block)
        ActiveSupport.on_load(:before_configuration, :yield => true, &block)
      end

      # Third configurable block to run. Does not run if config.cache_classes
      # set to false.
      def before_eager_load(&block)
        ActiveSupport.on_load(:before_eager_load, :yield => true, &block)
      end

      # Second configurable block to run. Called before frameworks initialize.
      def before_initialize(&block)
        ActiveSupport.on_load(:before_initialize, :yield => true, &block)
      end

      # Last configurable block to run. Called after frameworks initialize.
      def after_initialize(&block)
        ActiveSupport.on_load(:after_initialize, :yield => true, &block)
      end

      # Array of callbacks defined by #to_prepare.
      def to_prepare_blocks
        @@to_prepare_blocks ||= []
      end

      # Defines generic callbacks to run before #after_initialize. Useful for
      # Rails::Railtie subclasses.
      def to_prepare(&blk)
        to_prepare_blocks << blk if blk
      end

      def respond_to?(name)
        super || @@options.key?(name.to_sym)
      end

      # static_asset_paths is a Hash containing asset_paths
      # with associated public folders, like:
      # { "/" => "/app/public", "/my_engine" => "app/engines/my_engine/public" }
      def static_asset_paths
        @@static_asset_paths ||= ActiveSupport::OrderedHash.new
      end

    private

      def method_missing(name, *args, &blk)
        if name.to_s =~ /=$/
          @@options[$`.to_sym] = args.first
        elsif @@options.key?(name)
          @@options[name]
        else
          super
        end
      end
    end
  end
end
