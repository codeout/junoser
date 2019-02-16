## [0.3.4] - 2019-02-17

### Added

* Newly supported syntax
  * protocols bgp minimum-hold-time xxx
  * system dump-on-panic
  * chassis fpc x pic x port x number-of-sub-ports x


## [0.3.3] - 2018-10-09

### Fixed

* Accept quoted string for
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
  * class-of-service shared-buffer


## [0.2.11] - 2017-09-07

### Added

* Newly supported syntax
  * forwarding-options analyzer
  * routing-options dynamic-tunnels <name> udp


## [0.2.10] - 2017-08-22

### Fixed

* routing-options dynamic-tunnels


## [0.2.9] - 2017-06-09

### Added

* Newly supported syntax
  * protocols sflow


## [0.2.8] - 2017-05-17

### Fixed

* chassis forwarding-options


## [0.2.7] - 2017-05-01

### Added

* Newly supported syntax
  * system processes app-engine-virtual-machine-management-service
  * system processes app-engine-management-service
  * chassis fpc ? pic ? tunnel-services


## [0.2.6] - 2017-04-21

### Added

* Newly supported syntax
  * chassis fpc ? pic ? port ? channel-speed ?

## [0.2.5] - 2017-04-18

### Fixed

* "deactivate", "inactive: " statement processing


## [0.2.4] - 2017-02-18

### Added

* Newly supported syntax
  * system processes app-engine-virtual-machine-management-service traceoptions
  * Some platforms expect "system processes dhcp", not "system processes dhcp-service"
  * "storm-control" under family bridge

### Fixed

* Appropriately extract "vlan <vlan-name>"


## [0.2.3] - 2016-08-28

### Added

* Newly supported syntax
  * chassis fpc N error
  * forwarding-options sampling family mpls


## [0.2.2] - 2016-02-15

### Added

* Newly supported syntax
  * system services ssh

### Fixed

* choice syntax


## [0.2.1] - 2016-01-15

### Added

* Newly supported syntax
  * services flow-monitoring version9 template
* Start CI

### Fixed

* template-name


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

* 802.3ad
* ether-options
* storm-control default
* vrf-target
* maximum-prefix teardown
* traceoptions
* system syslog archive
* system login user
* routing-options confederation
* hold-time
* protocols ospf area x.x.x.x stub default-metric x x
* protocols rsvp interface xxx subscription x
* traceoptions cspf-link
* protocols mpls priority
* protocols mpls label-switched-path xxx primary xxx bandwidth xxx
* protocols xxx rib-group xxx xxx
* protocols mpls path xxx xxx


## [0.1.6] - 2015-10-31

### Fixed

* route-filter statement should be translated into one-line


## [0.1.5] - 2015-09-11

### Fixed

* mistakenly processed '{' and '}' in as-path string


## [0.1.4] - 2015-09-11

### Fixed

* missing community operator in policy-statement didn't fail


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
