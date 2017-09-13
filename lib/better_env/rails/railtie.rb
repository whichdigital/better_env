# frozen_string_literal: true
require 'better_env/rails/value'

module BetterEnv
  module Rails
    class Railtie < ::Rails::Railtie
      def root
        ::Rails.root || Pathname.new(ENV['RAILS_ROOT'] || Dir.pwd)
      end

      def environment
        @environment ||= ::Rails.env
      end

      def env
        @env ||= [File.join(root, '.env'), File.join(root, ".env.#{environment}")]
      end

      def config_file
        @config_file ||= File.join(root, 'config/better_env.yml')
      end

      def env_config
        @env_config ||= YAML.load_file(config_file)[environment]
      end

      def load
        BetterEnv.load(env_config, env, BetterEnv::Rails::Value)
      end

      def watch
        begin
          require 'spring/watcher'
        rescue LoadError
          BetterEnv.logger.debug('Spring is not present')
        else
          Spring.watch([config_file] + env)
        end
      end

      def self.load
        instance.load
      end

      config.before_configuration do
        load
        watch
      end
    end
  end
end
