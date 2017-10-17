require 'helper'

class TestCommunityOperator < Test::Unit::TestCase
  test 'community operator' do
    ['set policy-options policy-statement foo term term-foo then community add comm-foo',
     'set policy-options policy-statement foo then community add comm-foo'].each do |config|
      assert_true Junoser::Cli.commit_check(config)
    end
  end

  test 'community operator missing' do
    ['set policy-options policy-statement foo term term-foo then community comm-foo',
     'set policy-options policy-statement foo then community comm-foo'].each do |config|
      assert_false Junoser::Cli.commit_check(config)
    end
  end
end
