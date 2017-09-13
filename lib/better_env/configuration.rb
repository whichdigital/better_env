# frozen_string_literal: true
module BetterEnv
  class Configuration
    attr_reader :configuration

    def initialize(config)
      @configuration = load_configuration(config)
    end

    def get_value(key)
      configuration[key.to_s]&.value
    end

    def validate
      missing = configuration.select { |_, value| value.invalid? }.values.map(&:name)

      raise "Missing configuration variables: #{missing.join(', ')}" if missing.any?
    end

    private

    def load_configuration(config)
      config.each_with_object({}) do |variable, hash|
        hash[variable.name] = variable
      end
    end
  end
end
