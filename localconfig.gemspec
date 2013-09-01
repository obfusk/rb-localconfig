require File.expand_path('../lib/localconfig/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'localconfig'
  s.homepage    = 'https://github.com/obfusk/rb-localconfig'
  s.summary     = 'local configuration for ruby (web) apps'

  s.description = <<-END.gsub(/^ {4}/, '')
    local configuration for ruby (web) apps

    ...
  END

  s.version     = LocalConfig::VERSION
  s.date        = LocalConfig::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ GPLv2 EPLv1 }

  s.files       = %w{ .yardopts README.md Rakefile } \
                + %w{ localconfig.gemspec } \
                + Dir['{lib,spec}/**/*.rb']

  s.add_runtime_dependency 'hashie'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.required_ruby_version = '>= 1.9.1'
end
