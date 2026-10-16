# frozen_string_literal: true

require 'helper'
require 'junoser/development'

class TestXsd < Test::Unit::TestCase
  test 'positional arguments of an unbounded choice are a sequence' do
    xsd = <<~XSD
      <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <xsd:complexType name="monitor-threshold">
          <xsd:annotation>
            <xsd:appinfo>
              <flag>oneliner</flag>
            </xsd:appinfo>
          </xsd:annotation>
          <xsd:sequence>
            <xsd:choice minOccurs="0" maxOccurs="unbounded">
              <xsd:element name="normal">
                <xsd:annotation>
                  <xsd:appinfo>
                    <flag>nokeyword</flag>
                    <flag>mandatory</flag>
                  </xsd:appinfo>
                </xsd:annotation>
                <xsd:simpleType>
                  <xsd:restriction base="xsd:unsignedByte"/>
                </xsd:simpleType>
              </xsd:element>
              <xsd:element name="threshold">
                <xsd:annotation>
                  <xsd:appinfo>
                    <flag>nokeyword</flag>
                    <flag>mandatory</flag>
                  </xsd:appinfo>
                </xsd:annotation>
                <xsd:simpleType>
                  <xsd:restriction base="xsd:unsignedByte"/>
                </xsd:simpleType>
              </xsd:element>
            </xsd:choice>
          </xsd:sequence>
        </xsd:complexType>
      </xsd:schema>
    XSD

    assert_match(/s\(\s*arg,\s*arg\s*\)/, to_config(xsd))
  end

  test 'positional arguments of an unbounded choice are a sequence even if typed' do
    xsd = <<~XSD
      <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <xsd:complexType name="rib-aggregate-type">
          <xsd:sequence>
            <xsd:choice minOccurs="0" maxOccurs="unbounded">
              <xsd:element name="as-number" type="xsd:string">
                <xsd:annotation>
                  <xsd:appinfo>
                    <flag>nokeyword</flag>
                    <flag>mandatory</flag>
                  </xsd:appinfo>
                </xsd:annotation>
              </xsd:element>
              <xsd:element name="address" type="ipv4addr">
                <xsd:annotation>
                  <xsd:appinfo>
                    <flag>nokeyword</flag>
                    <flag>mandatory</flag>
                  </xsd:appinfo>
                </xsd:annotation>
              </xsd:element>
            </xsd:choice>
          </xsd:sequence>
        </xsd:complexType>
      </xsd:schema>
    XSD

    assert_match(/s\(\s*arg,\s*ipv4addr\s*\)/, to_config(xsd))
  end

  test 'a single argument of an unbounded choice is still a choice' do
    xsd = <<~XSD
      <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <xsd:complexType name="source-address-type">
          <xsd:sequence>
            <xsd:choice minOccurs="0" maxOccurs="unbounded">
              <xsd:element name="any"/>
              <xsd:element name="address">
                <xsd:annotation>
                  <xsd:appinfo>
                    <flag>nokeyword</flag>
                  </xsd:appinfo>
                </xsd:annotation>
              </xsd:element>
            </xsd:choice>
          </xsd:sequence>
        </xsd:complexType>
      </xsd:schema>
    XSD

    assert_match(/c\(\s*"any",\s*arg\s*\)/, to_config(xsd))
  end

  private

  def to_config(xsd)
    Nokogiri::XML(xsd).root.remove_unused.xpath('/xsd:schema/*').map(&:to_config).join
  end
end
