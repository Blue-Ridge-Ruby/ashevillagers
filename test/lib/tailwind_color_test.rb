require "test_helper"

class TailwindColorTest < ActiveSupport::TestCase
  test "method-style access returns level 500 by default" do
    c = TailwindColor.red
    assert_equal "red", c.hue
    assert_equal 500, c.level
  end

  test "method-style access with explicit level" do
    assert_equal 200, TailwindColor.red(200).level
  end

  test "bracket access by symbol and string returns level 500" do
    [:red, "red"].each do |key|
      c = TailwindColor[key]
      assert_equal "red", c.hue
      assert_equal 500, c.level
    end
  end

  test "bracket access with unknown hue returns nil (does not raise)" do
    assert_nil TailwindColor[:nonexistent]
  end

  test "method-style access with unknown hue raises" do
    assert_raises(NoMethodError) { TailwindColor.nonexistent }
  end

  test "unknown level raises" do
    assert_raises(ArgumentError) { TailwindColor.red(123) }
    assert_raises(ArgumentError) { TailwindColor.red.at(123) }
  end

  test "all yields one Color per hue at the requested level" do
    colors = TailwindColor.all.to_a
    assert_equal TailwindColor::HUES.size, colors.size
    assert(colors.all? { |c| c.level == 500 })
    assert_equal TailwindColor::HUES, colors.map(&:hue)

    assert(TailwindColor.all(700).all? { |c| c.level == 700 })
  end

  test "neutrals yields just the neutral hues" do
    assert_equal TailwindColor::NEUTRAL_HUES, TailwindColor.neutrals.map(&:hue)
    assert(TailwindColor.neutrals.all? { |c| c.level == 500 })
  end

  test "bolds(300) yields all bold hues at level 300" do
    bolds = TailwindColor.bolds(300).to_a
    assert_equal TailwindColor::BOLD_HUES, bolds.map(&:hue)
    assert(bolds.all? { |c| c.level == 300 })
  end

  test "color string is hue-level" do
    assert_equal "red-500", TailwindColor.red.color
    assert_equal "sky-200", TailwindColor.sky(200).color
  end

  test "oklch / oklab / rgb return expected shapes" do
    c = TailwindColor.red
    assert_equal 3, c.oklch.size
    assert(c.oklch.all? { |n| n.is_a?(Float) })
    assert_equal 3, c.oklab.size
    assert_equal 3, c.rgb.size
    assert(c.rgb.all? { |n| n.is_a?(Integer) && (0..255).cover?(n) })
  end

  test "Color#all yields all 11 levels for the hue" do
    levels = TailwindColor.red.all.map(&:level)
    assert_equal TailwindColor::LEVELS, levels
    assert(TailwindColor.red.all.all? { |c| c.hue == "red" })
  end

  test "Color#at returns a new Color with the same hue and given level" do
    assert_equal TailwindColor.red(800), TailwindColor.red.at(800)
  end

  test "Color is frozen and equality / hash work" do
    a = TailwindColor.red(400)
    b = TailwindColor.red(400)
    assert a.frozen?
    assert_equal a, b
    assert_equal a.hash, b.hash
    refute_equal a, TailwindColor.red(500)
  end

  test "neutrals and bolds together cover all hues without overlap" do
    assert_equal TailwindColor::HUES.sort, (TailwindColor::NEUTRAL_HUES + TailwindColor::BOLD_HUES).sort
    assert_empty TailwindColor::NEUTRAL_HUES & TailwindColor::BOLD_HUES
  end
end
