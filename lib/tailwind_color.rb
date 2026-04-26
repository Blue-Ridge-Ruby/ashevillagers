module TailwindColor
  NEUTRAL_HUES = %w[slate gray zinc neutral stone taupe mauve mist olive].freeze
  BOLD_HUES = %w[red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose].freeze
  HUES = (BOLD_HUES + NEUTRAL_HUES).freeze
  LEVELS = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950].freeze
  DEFAULT_LEVEL = 500

  class << self
    def [](hue)
      hue = hue.to_s
      Data::TABLE.key?(hue) ? Color.new(hue, DEFAULT_LEVEL) : nil
    end

    def all(level = DEFAULT_LEVEL)
      each_color(HUES, level)
    end

    def neutrals(level = DEFAULT_LEVEL)
      each_color(NEUTRAL_HUES, level)
    end

    def bolds(level = DEFAULT_LEVEL)
      each_color(BOLD_HUES, level)
    end

    def respond_to_missing?(name, include_private = false)
      Data::TABLE.key?(name.to_s) || super
    end

    def method_missing(name, *args, **)
      hue = name.to_s
      return super unless Data::TABLE.key?(hue)
      Color.new(hue, args.first || DEFAULT_LEVEL)
    end

    private

    def each_color(hues, level)
      Enumerator.new do |y|
        hues.each { |h| y << Color.new(h, level) }
      end
    end
  end
end
