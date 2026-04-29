require "test_helper"

class LazyAttributesTest < ActiveSupport::TestCase
  # ImageGeneration#prompt is the canonical example we test against — it's
  # column-backed via lazy_attribute and (unlike #animal) has no before_save
  # auto-populating it.

  test "computes value when blank and persists it" do
    ig = build_blank_prompt_ig
    assert_nil ig.attributes["prompt"]

    value = ig.prompt

    assert value.present?
    assert_equal value, ig.reload.prompt
  end

  test "returns the stored value without re-running the proc when present" do
    answer = profile_answers(:one_sport)
    ig = answer.create_image_generation!(animal: "preset_fox", prompt: "preset prompt")

    assert_no_difference -> { ig.updated_at } do
      assert_equal "preset prompt", ig.prompt
    end
  end

  test "ensure_<name> assigns without saving" do
    ig = build_blank_prompt_ig
    refute ig.prompt_changed?

    ig.ensure_prompt

    assert ig.prompt_changed?
    assert_nil ig.reload.attributes["prompt"]
  end

  test "does not save when not persisted" do
    answer = profile_answers(:one_sport)
    answer.update_column(:job_title, "Cyclist")
    ig = ImageGeneration.new(profile_answer: answer)

    value = ig.prompt

    assert value.present?
    refute ig.persisted?
  end

  private

  # A persisted ImageGeneration with a pre-cached job_title (so prompt's
  # generator can run without hitting the LLM) and a blank prompt column.
  def build_blank_prompt_ig
    answer = profile_answers(:one_sport)
    answer.update_column(:job_title, "Cyclist")
    ig = answer.create_image_generation!(animal: "fox")
    ig.update_column(:prompt, nil)
    ig
  end
end
