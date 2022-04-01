# frozen_string_literal: true

require_relative "lib/jekyll/gdocfilter/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-gdocfilter"
  spec.version       = Jekyll::Gdocfilter::VERSION
  spec.authors       = ["joe-irving"]
  spec.email         = ["joe@irving.me.uk"]

  spec.summary       = "A simple filter to turn a Google Doc into readable HTML"
  spec.description   = "A Jekyll filter that takes a link to a public google doc,
                        and returns HTML with basic styling to put on your pages"
  spec.homepage      = "https://github.com/tippingpointuk/jekyll-gdocfilter"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tippingpointuk/jekyll-gdocfilter/"
  spec.metadata["changelog_uri"] = "https://github.com/tippingpointuk/jekyll-gdocfilter/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "jekyll", ">= 3.7", "< 5.0"
  spec.add_dependency "nokogiri", ">=1.11.0", "<=1.13.3"
  spec.add_dependency "css_parser", "1.11.0"
  spec.add_dependency "open-uri", "0.2.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
