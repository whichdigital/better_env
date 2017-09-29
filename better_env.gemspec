# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'better_env/version'

Gem::Specification.new do |spec|
  spec.name          = 'better_env'
  spec.version       = BetterEnv::VERSION
  spec.authors       = ['Evgeni Spasov', 'Vasil Gochev']
  spec.email         = ['evgeni.spasov@which.co.uk', 'vasil.gochev@which.co.uk']

  spec.summary       = 'Better environment configuration.'
  spec.description   = 'Better environment configuration.'
  spec.homepage      = 'https://github.com/whichdigital/better_env'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'combustion', '~> 0.5.5'
end
