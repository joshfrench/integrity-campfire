Gem::Specification.new do |s|
  s.name              = "integrity-campfire"
  s.version           = "1.2.0"
  s.date              = "2009-3-26"
  s.summary           = "Campfire notifier for the Integrity continuous integration server"
  s.description       = "Easily let Integrity alert Campfire after each build"
  s.homepage          = "http://integrityapp.com"
  s.email             = "chris@ozmm.org"
  s.authors           = ["Chris Wanstrath"]
  s.has_rdoc          = false

  s.rubyforge_project = "integrity"

  s.add_dependency "integrity"
  s.add_dependency "tinder"

  if s.respond_to?(:add_development_dependency)
    s.add_development_dependency "mocha"
    s.add_development_dependency "sr-mg"
  end

  s.files             = %w[
README.markdown
Rakefile
integrity-campfire.gemspec
lib/integrity/notifier/campfire.rb
lib/integrity/notifier/config.haml
test/campfire_test.rb
test/helper.rb
]
end
