## [0.5.0] - 2022-11-02

### Added

* Recreate parser based on MX 21.2R3-S2.9 xsd


## [0.4.7] - 2022-09-20

### Added

* Faster interface speed up to 800g

### Fixed

* "interfaces interface-range xxx member-range"
* "classifiers" for QoS


## [0.4.6] - 2022-07-02

### Fixed

* Accept quoted strings under "system license keys key"
* "protocols bgp ... prefix-limit teardown"


## [0.4.5] - 2022-04-27

### Fixed

* Ignore "replace:" tag in structured form


## [0.4.4] - 2022-02-26

### Fixed

* "snmp name" instead of "snmp system-name"


## [0.4.3] - 2021-09-28

### Fixed

* A Nokogiri's [security vulnerability](https://github.com/advisories/GHSA-2rr5-8q37-2w7h)


## [0.4.2] - 2021-08-30

### Added

* Newly supported syntax
  * "virtual-chassis vcp-snmp-statistics"
  * "application_object"

### Fixed

* Keywords "tls", "group", "dest-nat-rule-match", "src-nat-rule-match", and "static-nat-rule-match" might be marked as invalid in some hierarchies
* "applications application xxx term xxx"
* "security"


## [0.4.1] - 2021-06-06

### Added

* Newly supported syntax
  * "apply-groups-except"

### Fixed

* Keywords "scpf-link", "https", "inet6", "icmp6", "icmpv6", "ospf3", and "snmptrap" might be marked as invalid in some hierarchies
* "policy-options community xxx members"
* "policy-options route-distinguisher xxx members"
* "routing-options confederation members"


## [0.4.0] - 2021-05-02

### Added

* Recreate parser based on MX 19.3R3-S1.3 xsd


## [0.3.13] - 2020-05-20

### Fixed

* Accept quoted strings under
  * "system login message"
  * "policy-options prefix-list xxx apply-path"

* <xsd:documentation/> processing during "rake build:config"
* <xsd:sequence><xsd:choice maxOccurs="unbounded"></xsd:sequence> should be considered as a sequence


## [0.3.12] - 2020-02-06

### Fixed

* "insert" statement whose last two tokens are keyword and argument, with the following single "before" (or "after") argument
  * eg) insert protocols bgp group foo export bar before baz


## [0.3.11] - 2020-01-28

### Added

* junoser-squash supports "activate" statement


## [0.3.10] - 2020-01-27

### Added

* junoser-squash experimentally supports "insert" statement

### Fixed

* junoser-squash unexpectedly kept statements intact due to tokenization bug
* junoser-squash unexpectedly removed "deactivate" statements
* "deactivate" to "inactive:" translation during "junoser -s"


## [0.3.9] - 2019-11-17

### Fixed

* security policies
* "junoser -s" and "junoser -d" unexpectedly raises errors


## [0.3.8] - 2019-11-04

### Added

* Newly supported syntax
  * "security" (by porting the hierarchy from vSRX 18.3R1.9)


## [0.3.7] - 2019-09-03

### Added

* Support "deactivate ... apply-groups"

### Fixed

* "apply-groups" translation between "display set" and structured form


## [0.3.6] - 2019-08-25

### Fixed

* Support "groups"


## [0.3.5] - 2019-08-15

### Fixed

* Accept quoted strings under
  * "as-path path"


## [0.3.4] - 2019-02-17

### Added

* Newly supported syntax
  * "protocols bgp minimum-hold-time xxx"
  * "system dump-on-panic"
  * "chassis fpc x pic x port x number-of-sub-ports x"


## [0.3.3] - 2018-10-09

### Fixed

* Accept quoted strings under
  * "snmp location"
  * "snmp contact"


## [0.3.2] - 2018-07-12

### Fixed

* Support "system services extension-service request-response grpc clear-text"
* Support "system services extension-service request-response grpc skip-authentication"


## [0.3.1] - 2018-03-03

### Added

* Introduce a CLI command "junoser-squash"

### Fixed

* Support "forwarding-options dhcp-relay server-group group_name x.x.x.x/y"


## [0.3.0] - 2017-10-26

### Changed

* First release based on JUNOS 17.2R1.13 of vMX


## [0.2.13] - 2017-10-13

### Fixed

* Support "protocols mpls" commands at "routing-instances" hierarchy


## [0.2.12] - 2017-10-06

### Added

* Newly supported syntax
  * "class-of-service shared-buffer"


## [0.2.11] - 2017-09-07

### Added

* Newly supported syntax
  * "forwarding-options analyzer"
  * "routing-options dynamic-tunnels <name> udp"


## [0.2.10] - 2017-08-22

### Fixed

* "routing-options dynamic-tunnels"


## [0.2.9] - 2017-06-09

### Added

* Newly supported syntax
  * "protocols sflow"


## [0.2.8] - 2017-05-17

### Fixed

* "chassis forwarding-options"


## [0.2.7] - 2017-05-01

### Added

* Newly supported syntax
  * "system processes app-engine-virtual-machine-management-service"
  * "system processes app-engine-management-service"
  * "chassis fpc ? pic ? tunnel-services"


## [0.2.6] - 2017-04-21

### Added

* Newly supported syntax
  * "chassis fpc ? pic ? port ? channel-speed ?"

## [0.2.5] - 2017-04-18

### Fixed

* "deactivate", "inactive: " statement processing


## [0.2.4] - 2017-02-18

### Added

* Newly supported syntax
  * "system processes app-engine-virtual-machine-management-service traceoptions"
  * Some platforms expect "system processes dhcp", not "system processes dhcp-service"
  * "storm-control" under family bridge

### Fixed

* Appropriately extract "vlan <vlan-name>"


## [0.2.3] - 2016-08-28

### Added

* Newly supported syntax
  * "chassis fpc N error"
  * "forwarding-options sampling family mpls"


## [0.2.2] - 2016-02-15

### Added

* Newly supported syntax
  * "system services ssh"

### Fixed

* choice syntax


## [0.2.1] - 2016-01-15

### Added

* Newly supported syntax
  * services flow-monitoring version9 template
* Start CI

### Fixed

* "template-name"


## [0.2.0] - 2015-12-26

### Added

* Newly supported syntax
  * Minimal configuration of MS-PIC/MIC based flow sampling

### Changed

* Use "choice" instead of "sequence of choices"
  * Sequence of choices comes from .xsd for NETCONF.
    It's required for XML but worthless and time wasting for CLI.
  * 150% fast!

### Fixed

* "802.3ad"
* "ether-options"
* "storm-control default"
* "vrf-target"
* "maximum-prefix teardown"
* "traceoptions"
* "system syslog archive"
* "system login user"
* "routing-options confederation"
* "hold-time"
* "protocols ospf area x.x.x.x stub default-metric x x"
* "protocols rsvp interface xxx subscription x"
* "traceoptions cspf-link"
* "protocols mpls priority"
* "protocols mpls label-switched-path xxx primary xxx bandwidth xxx"
* "protocols xxx rib-group xxx xxx"
* "protocols mpls path xxx xxx"


## [0.1.6] - 2015-10-31

### Fixed

* "route-filter" statement should be translated into one-line


## [0.1.5] - 2015-09-11

### Fixed

* Mistakenly processed '{' and '}' in as-path string


## [0.1.4] - 2015-09-11

### Fixed

* Missing community operator in policy-statement didn't fail


## [0.1.3] - 2015-07-26

### Added

* Newly supported syntax
  * "chassis ... sampling-instance"
  * "forwarding-options sampling instance"
  * "chassis forwarding-options"
  * "protocols layer2-control"
* Add tests

### Changed

* Cosmetic changes on structured config translation

### Fixed

* Bug fix
  * "confederation-as" statement
  * "next-hop" statement
  * "junoser -v" didn't work
  * comment line handling


## [0.1.2] - 2015-07-14

### Fixed

* Bug fix


## [0.1.1] - 2015-07-14

### Changed

* Now "commit_check" method returns boolean

### Fixed

* Bug fixes


## [0.1.0] - 2015-07-14

### Added

* First release
