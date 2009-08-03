require 'test/unit'
require 'rr'
require 'integrity/notifier/test'

require File.dirname(__FILE__) + '/../lib/integrity/notifier/campfire'

class Array
  def pick
    slice(Kernel.rand(size))
  end
end