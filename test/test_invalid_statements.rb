require 'helper'

class TestInvalidStatements < Test::Unit::TestCase
  test 'syntax check to fail' do
    config = <<~EOS
      set protocols ospf area 0.0.0.0 export opsf-export
    EOS

    config.split("\n").each do |l|
      assert_false Junoser::Cli.commit_check(l), %["#{l}" should be invalid]
    end
  end
end
