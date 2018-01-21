# frozen_string_literal: true

require 'better_env'

BetterEnv::Rails::Railtie.load

BetterEnv.configuration.configuration.each do |key, value|
  ENV[key.to_s] ||= value.value.to_s
end
