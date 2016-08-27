module Underscorable
  # Port from activesupport-4.2.7.1/lib/active_support/inflector/methods.rb
  def underscore
    return self unless self =~ /[A-Z-]|::/
    word = self.to_s.gsub(/::/, '/')
    word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)((?=a)b)(?=\b|[^a-z])/) { "#{$1 && '_'}#{$2.downcase}" }
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

String.include Underscorable
