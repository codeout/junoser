require 'test-unit'
require 'junoser'

class TestCommentLine < Test::Unit::TestCase
  display_set_config = <<-EOS
 /* a comment */
 # a comment
 /*
  * a comment
  */
set system  /* a comment */
set system  # a comment
set interfaces lo0 description "/*"  /* a comment */
set system root-authentication encrypted-password "#"  # a comment
 /* a comment */ set system
    EOS

  structured_config = <<-EOS
 /* a comment */
 # a comment
 /*
  * a comment
  */
interfaces {  /* a comment */
/* a comment */  lo0 {
    description "/*";  /* a comment */
  }
  ge-0/0/0 {  # a comment
    description "#";  # a comment
  }
}
    EOS

  test 'commit check display-set style' do
    assert_true Junoser::Cli.commit_check(display_set_config)
  end

  test 'commit check structured style' do
    assert_true Junoser::Cli.commit_check(structured_config)
  end

  test 'transform into structured style' do
    assert_match /system {\s*root-authentication {\s*encrypted-password "#";\s*}\s*}\s*interfaces lo0 {\s*description "\/\*";\s*}/,
                 Junoser::Cli.struct(display_set_config)
  end

  test 'transform into display-set style' do
    assert_match /set interfaces lo0 description "\/\*"\nset interfaces ge-0\/0\/0 description "#"/,
                 Junoser::Cli.display_set(structured_config)
  end
end
