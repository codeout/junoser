require 'helper'

class TestCarriageReturn < Test::Unit::TestCase
  test 'commit check display-set style' do
    commands = ['set system login user a', 'set system login user b']
    assert_true Junoser::Cli.commit_check(commands.join("\n"))
    assert_true Junoser::Cli.commit_check(commands.join("\r"))
    assert_true Junoser::Cli.commit_check(commands.join("\r\n"))
  end

  test 'commit check structured style' do
    commands = ['system {', 'login {', 'user a;', '}', '}']
    Junoser::Cli.commit_check(commands.join("\n"))
    Junoser::Cli.commit_check(commands.join("\r"))
    Junoser::Cli.commit_check(commands.join("\r\n"))
  end

  test 'transform into structured style' do
    commands = ['set system login user a', 'set system login user b']
    pattern = /system {\s*login {\s*user a;\s*user b;\s*}\s*}/
    assert_match pattern, Junoser::Cli.struct(commands.join("\n"))
    assert_match pattern, Junoser::Cli.struct(commands.join("\r"))
    assert_match pattern, Junoser::Cli.struct(commands.join("\r\n"))
  end

  test 'transform into display-set style' do
    commands = ['system {', 'login {', 'user a;', '}', '}']
    pattern = 'system login user a'
    assert_match pattern, Junoser::Cli.display_set(commands.join("\n"))
    assert_match pattern, Junoser::Cli.display_set(commands.join("\r"))
    assert_match pattern, Junoser::Cli.display_set(commands.join("\r\n"))
  end
end
