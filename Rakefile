task :default => :test

task :test do
  ruby "test/campfire_test.rb"
end

begin
  require "mg"
  MG.new("integrity-campfire.gemspec")
rescue LoadError
end
