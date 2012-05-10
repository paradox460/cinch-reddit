# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Jeff Sandberg"]
  gem.email         = ["paradox460@gmail.com"]
  gem.description   = <<-EOF
    This is a simple reddit plugin for the excellent cinch irc bot framework.
    It provides a few simple commands, !karma, !mods, and !readers.
      + !karma <user> returns the karma of a reddit.com user account
      + !mods <subreddit> returns the moderators of a reddit.com subreddit
      + !readers <subreddit> returns the subscriber count of a subreddit.
  EOF
  gem.summary       = %q{A reddit plugin for the cinch irc bot framework}
  gem.homepage      = "http://paradox.gd"

  gem.add_dependency "cinch"
  gem.add_dependency "json"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cinch-reddit"
  gem.require_paths = ["lib"]
  gem.version       = "1.0.0"
end
