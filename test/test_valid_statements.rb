require 'helper'

class TestValidStatements < Test::Unit::TestCase
  test 'syntax check to pass' do
    config = <<~EOS
      set services service-set xxx nat-rules xxx
      set services service-set xxx next-hop-service inside-service-interface xxx
      set services service-set xxx next-hop-service outside-service-interface xxx

      set routing-instances xxx protocols bgp drop-path-attributes 128

      set apply-groups xxx

      set virtual-chassis preprovisioned
      set virtual-chassis no-split-detection
      set virtual-chassis member 0 role routing-engine
      set virtual-chassis member 0 serial-number xxx
      set virtual-chassis mac-persistence-timer disable

      set interfaces ge-0/0/0 unit 0 family ethernet-switching storm-control default
      set system ports console log-out-on-disconnect
      set protocols bfd traceoptions file xxx
      set system services ssh no-passwords
      set protocols vstp interface ge-0/0/0
      set forwarding-options sampling instance xxx input rate 1000
      set forwarding-options sampling instance xxx family inet output flow-server 10.0.0.1 port 2055
      set forwarding-options sampling instance xxx family inet output flow-server 10.0.0.1 version9 template

      set chassis forwarding-options lpm-profile prefix-65-127-disable
      set protocols layer2-control nonstop-bridging

      set protocols rsvp interface xxx subscription y
      set protocols mpls label-switched-path xxx primary yyy bandwidth zzz
      set protocols mpls priority 1 1

      set routing-options rib-groups xxx import-rib xxx.inet.0
      set routing-options rib-groups xxx import-policy xxx

      set services flow-monitoring version9 template xxx mpls-ipv4-template label-position 1
      set services flow-monitoring version9 template xxx mpls-ipv4-template label-position 2
      set services flow-monitoring version9 template xxx ipv4-template
      set services service-set inet-flow jflow-rules sampling
      set services service-set inet-flow sampling-service service-interface ms-0/0/0.0
      set services service-set mpls-flow jflow-rules sampling
      set services service-set mpls-flow sampling-service service-interface ms-0/0/0.0
      set forwarding-options sampling family inet output flow-server 10.0.0.1 version9 template xxx
      set forwarding-options sampling family inet output interface ms-0/0/0.0 source-address 10.0.0.1
      set forwarding-options sampling family mpls output flow-server 10.0.0.1 port 2055
      set forwarding-options sampling family mpls output flow-server 10.0.0.1 version9 template xxx
      set forwarding-options sampling family mpls output interface ms-0/0/0.0 source-address 10.0.0.1

      set chassis fpc xxx error
      set interfaces ge-0/0/0 unit 0 family bridge storm-control
      set system processes app-engine-virtual-machine-management-service traceoptions
      set system processes dhcp-service disable

      set class-of-service shared-buffer
      set class-of-service interfaces all unit * classifiers exp foo
      set class-of-service interfaces all unit 1 classifiers exp foo
      set routing-options dynamic-tunnels foo udp

      set protocols sflow agent-id 10.0.0.1
      set protocols sflow sample-rate ingress 1000
      set protocols sflow source-ip 10.0.0.1
      set protocols sflow collector 10.0.0.1

      set chassis fpc 0 pic 0 tunnel-services
      set system processes app-engine-management-service
      set system processes app-engine-virtual-machine-management-service
      set chassis fpc 0 pic 0 port 0 channel-speed 10g

      set ethernet-switching-options storm-control interface all level 50

      set protocols igmp-snooping vlan all disable
      set bridge-domains foo protocols igmp-snooping vlan all disable
      set routing-instances foo protocols igmp-snooping vlan all disable

      set protocols dcbx disable
      set protocols lldp-med disable

      set forwarding-options analyzer
      set forwarding-options analyzer foo input egress interface ge-0/0/0.0
      set forwarding-options analyzer foo output interface ge-0/0/0.0

      set system services extension-service request-response grpc clear-text port 50051
      set system services extension-service request-response grpc skip-authentication
      set system services extension-service notification allow-clients address 0.0.0.0/0

      set routing-instances xxx forwarding-options dhcp-relay server-group xxx 10.0.0.1

      set snmp contact "foo bar"
      set snmp location "foo bar"
      set snmp name foo
      set snmp name "foo bar"

      set protocols bgp minimum-hold-time 10
      set system dump-on-panic

      set chassis fpc 0 number-of-ports 8
      set chassis fpc 0 pic 0 port 0 number-of-sub-ports 0

      set routing-options rib inet6.0 aggregate route 2001:db8::/64 as-path path "65000 65000"
      set routing-options aggregate route 10.0.0.1/24 as-path path "65000 65000 65000"

      set security alg dns disable
      set security alg h323 disable
      set security alg rtsp disable
      set security alg sip disable
      set security forwarding-options family inet6 mode packet-based
      set security forwarding-options family mpls mode packet-based
      set security forwarding-options family iso mode packet-based

      set security policies from-zone xxx to-zone xxx policy xxx match source-address 10.0.0.1

      set system syslog time-format year millisecond
      set protocols mpls path foo 10.0.0.1 loose

      set interfaces ge-0/0/0 ether-options 802.3ad ae0
      set interfaces ge-0/0/0 ether-options 802.3ad lacp force-up
      set interfaces ge-0/0/0 ether-options 802.3ad lacp port-priority 1

      set policy-options prefix-list ipvX-bgp-neighbors apply-path "routing-instances <*> protocols bgp group <*> neighbor <*>"

      set protocols isis source-packet-routing ldp-stitching
      set protocols isis source-packet-routing mapping-server foo
      set protocols ldp sr-mapping-client
      set routing-options source-packet-routing mapping-server-entry foo prefix-segment 10.0.0.1/32 index 1

      set forwarding-options rpf-loose-mode-discard family inet6
      set policy-options policy-statement BGP_Customer_out term aggregates6 from protocol ospf3
      set policy-options policy-statement BGP_aggregate_contributors term internal_only from protocol ospf3

      set virtual-chassis vcp-snmp-statistics

      set services ssl initiation profile syslog-tls-profile protocol-version tls12

      set applications application idrac-app1 term t1 protocol tcp destination-port 5900

      set security log stream syslog-tls-stream host port 6514
      set security log stream syslog-tls-stream-eqiad host port 6514
      set security address-book global address pypi.python.org dns-name pypi.python.org
      set security nat static rule-set static-nat rule foo match destination-address xxx/32
      set security nat source rule-set foo-nat rule foo match source-address-name bar
      set security nat source rule-set foo-nat rule foo match destination-address-name bar

      set system license keys key foo
      set system license keys key "bar baz"

      set protocols bgp group foo family inet unicast prefix-limit teardown
      set protocols bgp group foo family inet unicast prefix-limit teardown
      set protocols bgp group foo family inet unicast prefix-limit teardown idle-timeout
      set protocols bgp group foo family inet unicast prefix-limit teardown idle-timeout 60
      set protocols bgp group foo family inet unicast prefix-limit teardown idle-timeout forever
      set protocols bgp group foo family inet unicast prefix-limit teardown 80
      set protocols bgp group foo family inet unicast prefix-limit teardown 80 idle-timeout
      set protocols bgp group foo family inet unicast prefix-limit teardown 80 idle-timeout 60
      set protocols bgp group foo family inet unicast prefix-limit teardown 80 idle-timeout forever

      set interfaces interface-range foo member-range ge-0/0/0 to ge-0/0/2

      set interfaces et-0/0/0 speed 100g
      set interfaces et-0/0/0 speed 200g
      set interfaces et-0/0/0 speed 400g
      set interfaces et-0/0/0 speed 800g
      set chassis fpc 0 pic 0 pic-mode 100G
      set chassis fpc 0 pic 0 pic-mode 400G
      set chassis fpc 0 pic 0 pic-mode 800G

      set poe interface ge-0/0/0 priority high telemetries duration 24
      set poe interface ge-0/0/1
      set poe interface ge-0/0/5 maximum-power 18.6
      set poe interface ge-5/0/7 disable

      set protocols iccp peer 10.9.8.54 liveness-detection single-hop
    EOS

    config.split("\n").each do |l|
      assert_true Junoser::Cli.commit_check(l), %["#{l}" should be valid]
    end
  end
end
