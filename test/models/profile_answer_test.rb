require "test_helper"

class ProfileAnswerTest < ActiveSupport::TestCase
  # -- job_title (lazy_attribute) --

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

  test "job_title does not call the LLM when value is already cached" do
    answer = profile_answers(:one_sport)
    answer.update_column(:job_title, "Cyclist")

    # If it called the LLM with the test fixture's stub-model, this would raise
    # RubyLLM::ModelNotFoundError. Reaching the assertion proves no LLM call.
    assert_equal "Cyclist", answer.job_title
  end

  # -- Configurable integration --

  test "model_for_job_title is registered as an expected configuration name" do
    assert_includes Configuration.expected_names, "model_for_job_title"
  end

  test "model_for_job_title is accessible as an instance method" do
    assert_equal "stub-model", profile_answers(:one_sport).model_for_job_title
  end
end
