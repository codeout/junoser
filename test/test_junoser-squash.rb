require 'pathname'

require 'helper'
require 'junoser/squash'


class TestCommentLine < Test::Unit::TestCase
  test 'check subcommand function' do
    config = <<-EOS
set interfaces em0 unit 0 family inet address 192.0.2.1/32
set interfaces em0 unit 0 family inet
set interfaces em100 unit 0 family inet
set interfaces em100 unit 0 family inet address 192.0.2.1/32
    EOS

    assert_equal('set interfaces em0 unit 0 family inet address 192.0.2.1/32
set interfaces em100 unit 0 family inet
set interfaces em100 unit 0 family inet address 192.0.2.1/32', Junoser::Squash.new(config).transform)
  end

  test 'check delete function' do
    config = <<-EOS
set interfaces em0 unit 0 family inet address 192.0.2.0/32
set interfaces em10 unit 10 family inet address 192.0.2.0/32
set interfaces em10 unit 10 family inet mtu 1500
set interfaces em10 unit 20
set interfaces em100 unit 100 family inet address 192.0.2.0/32
set interfaces em100 unit 200 family inet6
delete interfaces em0 unit 0 family inet address 192.0.2.0/32
delete interfaces em10 unit 10
delete interfaces em100 unit 200
    EOS

    assert_equal('set interfaces em0 unit 0 family inet address 192.0.2.0/32
set interfaces em10
set interfaces em10 unit 20
set interfaces em100 unit 100 family inet address 192.0.2.0/32', Junoser::Squash.new(config).transform)
  end
end
