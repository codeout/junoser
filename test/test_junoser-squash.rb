require 'pathname'

$: << File.expand_path('../', Pathname.new(__FILE__).realpath)
require 'helper'

$: << File.expand_path('../../lib', Pathname.new(__FILE__).realpath)
require 'junoser/squash'


class TestCommentLine < Test::Unit::TestCase
  config_subcommand = <<-EOS
set interfaces em0 unit 0 family inet address 192.0.2.1/32
set interfaces em0 unit 0 family inet
set interfaces em100 unit 0 family inet
set interfaces em100 unit 0 family inet address 192.0.2.1/32
EOS

  config_delete = <<-EOS
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

  # config_insert
  # ...
  # config_squash

  test 'check subcommand function' do
    assert_equal('set interfaces em0 unit 0 family inet address 192.0.2.1/32
set interfaces em100 unit 0 family inet
set interfaces em100 unit 0 family inet address 192.0.2.1/32',Junoser::Squash.new(config_subcommand).transform)

  end

  test 'check delete function' do
    assert_equal('set interfaces em0 unit 0 family inet address 192.0.2.0/32
set interfaces em10
set interfaces em10 unit 20
set interfaces em100 unit 100 family inet address 192.0.2.0/32',Junoser::Squash.new(config_delete).transform)

  end
end
