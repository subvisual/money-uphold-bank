# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "money-uphold-bank"
  spec.version       = "0.0.3"
  spec.authors       = ["Miguel Palhas"]
  spec.email         = ["miguel@subvisual.co"]

  spec.description   = %q(A gem that calculates the exchange rate using published rates from uphold.com. Compatible with the money gem)
  spec.summary       = %q(A gem that calculates the exchange rate using published rates from uphold.com.)
  spec.homepage      = "https://github.com/subvisual/#{spec.name}"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "money", "~> 6.12"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.37.2"
  spec.add_development_dependency "webmock", "~> 2.1.0"
end
