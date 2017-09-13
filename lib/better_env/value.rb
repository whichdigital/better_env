# frozen_string_literal: true
module BetterEnv
  class Value
    attr_reader :name, :value, :type, :default, :required

    def initialize(name, config, env_value, dotenv_value)
      @name = name
      @type = config['type']
      @default = config['default']
      @required = config['required'] == true
      @value = fetch_value(env_value, dotenv_value)
    end

    def invalid?
      empty_value?(value) && required
    end

    private

    def fetch_value(env_value, dotenv_value)
      value = if !empty_value?(env_value)
                env_value
              elsif !empty_value?(dotenv_value)
                dotenv_value
              elsif !required
                default_value
              end

      cast_type(value) unless value.nil?
    end

    def empty_value?(value)
      value.nil? || value.to_s.strip.empty?
    end

    def default_value
      if default == 'empty'
        ''
      else
        default
      end
    end

    def cast_type(value)
      cast_method = "to_#{type}"

      if respond_to? cast_method, true
        send(cast_method, value)
      else
        value&.to_s
      end
    end

    def to_boolean(string)
      string == true || string.to_s.casecmp('true').zero?
    end

    def to_integer(string)
      string.to_i
    end

    def to_minutes(string)
      string.to_i * 60
    end

    def to_path(string)
      File.join string.split('/').reject(&:empty?)
    end

    def to_url(string)
      string.chomp('/')
    end

    def to_symbol(string)
      string.to_sym
    end
  end
end
