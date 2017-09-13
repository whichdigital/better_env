# frozen_string_literal: true
require 'rails_helper'

describe BetterEnv::Rails::Railtie do
  it 'loads environment specific .env file' do
    expect(BetterEnv['TIMEOUT']).not_to be_nil
  end

  it 'has only the configuration for current Rails environment' do
    expect(BetterEnv.configuration.configuration.keys).to eq %w(COMMON_CONFIG TIMEOUT)
  end

  it 'casts :minutes type to ActiveSupport::Duration' do
    expect(BetterEnv['TIMEOUT']).to be_a ActiveSupport::Duration
  end
end
