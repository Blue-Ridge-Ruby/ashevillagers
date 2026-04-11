require "test_helper"

class ProfileQuestionTest < ActiveSupport::TestCase
  test "validates question presence" do
    pq = ProfileQuestion.new
    refute pq.valid?
    assert pq.errors[:question].any?
  end

  test "active scope returns only active questions ordered by position" do
    active = ProfileQuestion.active
    assert active.all?(&:active?)
    assert_equal active.map(&:position), active.map(&:position).sort
  end

  test "active scope excludes inactive questions" do
    refute_includes ProfileQuestion.active, profile_questions(:inactive_question)
  end
end
