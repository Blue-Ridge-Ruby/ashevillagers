require "test_helper"

class ProfileAnswerTest < ActiveSupport::TestCase
  # -- job_title with cached value --

  test "job_title returns stored value when present" do
    answer = profile_answers(:one_sport)
    answer.update_column(:job_title, "Cyclist")

    assert_equal "Cyclist", answer.job_title
  end

  test "job_title returns nil when answer is blank" do
    answer = profile_answers(:one_sport)
    answer.answer = ""

    assert_nil answer.job_title
  end

  # -- job_title calls LLM when not cached --

  test "job_title calls LLM and caches result when not stored" do
    answer = profile_answers(:one_sport)
    answer.update_column(:job_title, nil)

    stub_llm_response("Cyclist") do
      assert_equal "Cyclist", answer.job_title
      assert_equal "Cyclist", answer.reload.job_title
    end
  end

  test "job_title does not call LLM when value is already cached" do
    answer = profile_answers(:one_sport)
    answer.update_column(:job_title, "Cyclist")

    # No stub needed — if it calls the LLM this will error
    assert_equal "Cyclist", answer.job_title
  end

  # -- regenerate_job_title! --

  test "regenerate_job_title! clears and re-fetches" do
    answer = profile_answers(:one_sport)
    answer.update_column(:job_title, "Cyclist")

    stub_llm_response("Mountain Biker") do
      result = answer.regenerate_job_title!
      assert_equal "Mountain Biker", result
      assert_equal "Mountain Biker", answer.reload.job_title
    end
  end

  # -- Configurable integration --

  test "model_for_job_title is registered as an expected configuration name" do
    assert_includes Configuration.expected_names, "model_for_job_title"
  end

  test "model_for_job_title is accessible as an instance method" do
    Configuration.create!(name: "model_for_job_title", value: "gpt-4.1-nano")
    ProfileAnswer.reload_configuration!

    assert_equal "gpt-4.1-nano", profile_answers(:one_sport).model_for_job_title
  ensure
    Configuration.find_by(name: "model_for_job_title")&.destroy
    ProfileAnswer.reload_configuration!
  end

  private

  def stub_llm_response(content)
    ProfileAnswer.define_method(:get_job_title) { content }
    yield
  ensure
    ProfileAnswer.remove_method(:get_job_title)
  end
end
