require 'test/unit'

require 'junoser'


module Silent
  def print(arg)
  end

  def puts(arg)
  end
end

$stderr.extend Silent
