# frozen_string_literal: true
require 'better_env/version'
require 'better_env/value'
require 'better_env/configuration'
require 'better_env/rails/railtie' if defined? Rails
require 'logger'

module BetterEnv
  class << self
    attr_reader :configuration, :options, :env, :rails_root
    attr_accessor :app_root

    def load(options, env_files, value_class = BetterEnv::Value)
      env = load_env_files(env_files)
      options = load_options(options)

      variables = options.map do |key, config|
        value_class.new(key, config, ENV[key], env[key])
      end

      @configuration = Configuration.new variables
      configuration.validate
    end

    def [](key)
      configuration.get_value(key)
    end

    def logger
      @logger ||= begin
        logger = Logger.new(STDOUT)
        logger.level = Logger::INFO
        logger.formatter = proc do |severity, datetime, _, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} -- BetterEnv: #{msg}\n"
        end
        logger
      end
    end

    def inspect
      configuration.inspect
    end

    private

    def load_options(options)
      if options.is_a? String
        YAML.load_file(options)
      else
        options
      end
    end

    def load_env_files(files)
      files.each_with_object({}) do |file, hash|
        hash.merge! env_file_to_hash(file)
      end
    end

    def env_file_to_hash(file)
      return {} unless File.exist?(file)

      File.readlines(file).each_with_object({}) do |line, hash|
        line = line.split('#').first&.strip
        next if line.nil? || line.empty?

        key, value = line.split('=')
        hash[key] = value
      end
    end
  end
end
