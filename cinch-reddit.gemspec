# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Jeff Sandberg"]
  gem.email         = ["paradox460@gmail.com"]
  gem.description   = <<-EOF
    This is a simple reddit plugin for the excellent cinch irc bot framework.
    It provides a few simple commands, !karma, !mods, and !readers.
    See the github page for more details
  EOF
  gem.summary       = %q{A reddit plugin for the cinch irc bot framework}
  gem.homepage      = "http://github.com/paradox460/cinch-reddit"

  # Clean way to handle add_dependency
  %w{cinch json actionpack}.each { |x| gem.add_dependency x }

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cinch-reddit"
  gem.require_paths = ["lib"]
  gem.version       = "1.1.1"
end
