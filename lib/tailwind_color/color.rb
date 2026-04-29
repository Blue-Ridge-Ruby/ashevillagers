module TailwindColor
  class Color
    attr_reader :hue, :level

    def initialize(hue, level = DEFAULT_LEVEL)
      hue = hue.to_s
      raise ArgumentError, "Unknown hue: #{hue.inspect}" unless Data::TABLE.key?(hue)
      raise ArgumentError, "Unknown level: #{level.inspect}" unless Data::TABLE[hue].key?(level)
      @hue = hue
      @level = level
      freeze
    end

    def color = "#{hue}-#{level}"
    def var = "--color-#{color}"
    def oklch = Data::TABLE[hue][level][:oklch]
    def oklch_css(alpha = 1) = "oklch(%.3f %.3f %.3f / %.2f)" % [*oklch, alpha.clamp(0, 1)] # standard:disable Lint/FormatParameterMismatch
    def oklab = Data::TABLE[hue][level][:oklab]
    def rgb = Data::TABLE[hue][level][:rgb]
    def rgb_css = "#%02x%02x%02x" % rgb

    def at(level)
      self.class.new(hue, level)
    end

    def all
      Enumerator.new do |y|
        Data::TABLE[hue].each_key { |lv| y << self.class.new(hue, lv) }
      end
    end

    def ==(other)
      other.is_a?(Color) && other.hue == hue && other.level == level
    end
    alias_method :eql?, :==

    def hash = [hue, level].hash
    def to_s = color
    def inspect = "#<#{self.class.name} #{color}>"
  end
end
