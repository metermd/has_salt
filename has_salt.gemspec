lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "has_salt"
  spec.version       = '0.1.0'
  spec.authors       = ["Mike Owens"]
  spec.email         = ["mike@filespanker.com"]
  spec.description   = "ActiveRecord extension generates salt columns"
  spec.summary       = "Generate salt columns"
  spec.homepage      = "https://github.com/mieko/has_salt"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.2.0"
  spec.add_development_dependency "sqlite3"

  spec.add_dependency "activerecord", ">= 4.0.0"
  spec.required_ruby_version = "> 1.9.3"
end
