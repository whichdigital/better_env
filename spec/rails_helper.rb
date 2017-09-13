# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler'

Bundler.require :default, :development

Combustion.initialize!

require 'better_env/rails/railtie'
