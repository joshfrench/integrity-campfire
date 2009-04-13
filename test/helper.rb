require "test/unit"
require "mocha"
require "integrity/notifier/test"
require "redgreen"

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require "notifier/campfire"

class Test::Unit::TestCase
  include Integrity::Notifier::Test
end

# NOTE: Because of a bug in integrity/notifier/test/fixtures
class Array
  def pick
    slice(Kernel.rand(size))
  end
end

##
# test/spec/mini 2
# http://gist.github.com/25455
# chris@ozmm.org
#
def context(*args, &block)
  return super unless (name = args.first) && block
  klass = Class.new(defined?(ActiveSupport::TestCase) ? ActiveSupport::TestCase : Test::Unit::TestCase) do
    def self.test(name, &block)
      define_method("test_#{name.gsub(/\W/,"_")}", &block) if block
    end
    def self.xtest(*args) end
    def self.setup(&block) define_method(:setup, &block) end
    def self.teardown(&block) define_method(:teardown, &block) end
  end
  klass.class_eval &block
end
