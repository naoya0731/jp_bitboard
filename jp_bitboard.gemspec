# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jp_bitboard/version'

Gem::Specification.new do |spec|
  spec.name          = "jp_bitboard"
  spec.version       = JpBitboard::VERSION
  spec.authors       = ["naoya0731"]
  spec.email         = ["zosulab@gmail.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://mygemserver.com"
  end

  spec.summary       = %q{Bitcoinの国内取引所のAPIラッパー}
  spec.description   = %q{Bitcoinを日本円で取引できる取引所の公開APIから簡単に情報を取得できます。}
  spec.homepage      = "https://github.com/naoya0731/jp_bitboard"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
