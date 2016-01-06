# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_shop/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_shop"
  spec.version       = RailsShop::VERSION
  spec.authors       = ["Ilya N. Zykin"]
  spec.email         = ["zykin-ilya@ya.ru"]
  spec.summary       = %q{RAILS SHOP}
  spec.description   = %q{RAILS SHOP engine}
  spec.homepage      = "https://github.com/the-teacher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'slim'
  spec.add_dependency 'config'

  spec.add_dependency 'pagination'
  spec.add_dependency 'simple_sort'
  spec.add_dependency 'to_slug_param'
  spec.add_dependency 'the_string_addon'

  spec.add_dependency 'log_js'
  spec.add_dependency 'ptz_tabs'
  spec.add_dependency 'role_slim_js'
  spec.add_dependency 'notifications'
  spec.add_dependency 'awesome_nested_set'

  spec.add_dependency 'protozaur'
  spec.add_dependency 'protozaur_theme'
  spec.add_dependency 'table_holy_grail_layout'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
