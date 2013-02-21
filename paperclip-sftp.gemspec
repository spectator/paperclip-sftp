# -*- encoding: utf-8 -*-
require File.expand_path('../lib/paperclip-sftp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yury Velikanau"]
  gem.email         = ["yury.velikanau@gmail.com"]
  gem.description   = %q{SFTP (Secure File Transfer Protocol) storage for Paperclip.}
  gem.summary       = %q{SFTP (Secure File Transfer Protocol) storage for Paperclip.}
  gem.homepage      = "https://github.com/spectator/paperclip-sftp"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "paperclip-sftp"
  gem.require_paths = ["lib"]
  gem.version       = Paperclip::Sftp::VERSION

  gem.required_ruby_version = ">= 1.9.2"

  gem.add_dependency "paperclip", ">= 3.2.0"
  gem.add_dependency "net-sftp",  ">= 2.0.5"

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "minitest_should"
  gem.add_development_dependency "sqlite3"
end
