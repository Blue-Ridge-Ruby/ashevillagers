require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "belongs to villager" do
    assert_equal villagers(:one), profiles(:one).villager
  end

  test "villager has one profile" do
    assert_equal profiles(:one), villagers(:one).profile
  end

  test "to_param includes id and name" do
    profile = profiles(:one)
    assert_match(/^\d+-jane-doe$/, profile.to_param)
  end

  test "has_social_links? returns true when any link present" do
    assert profiles(:one).has_social_links?
  end

  test "has_social_links? returns false when no links present" do
    profile = Profile.new(villager: villagers(:unlinked), first_name: "Pat", last_name: "Taylor")
    refute profile.has_social_links?
  end

  test "validates first_name and last_name presence" do
    profile = Profile.new(villager: villagers(:unlinked))
    refute profile.valid?
    assert profile.errors[:first_name].any?
    assert profile.errors[:last_name].any?
  end

  test "answer_for returns the answer for a given question" do
    profile = profiles(:one)
    assert_equal "Mountain biking", profile.answer_for(profile_questions(:sport))
  end

  test "answer_for returns nil when no answer exists" do
    profile = profiles(:two)
    assert_nil profile.answer_for(profile_questions(:degree))
  end

  test "suggest_name_from_villager! populates from villager when blank" do
    profile = Profile.new(villager: villagers(:one))
    profile.suggest_name_from_villager!
    assert_equal "Jane", profile.first_name
    assert_equal "Doe", profile.last_name
  end

  test "suggest_name_from_villager! does not overwrite existing name" do
    profile = Profile.new(villager: villagers(:one), first_name: "Custom", last_name: "Name")
    profile.suggest_name_from_villager!
    assert_equal "Custom", profile.first_name
    assert_equal "Name", profile.last_name
  end

  test "ensure_answers_for builds missing answers" do
    profile = profiles(:one)
    questions = ProfileQuestion.active
    profile.ensure_answers_for(questions)
    assert_equal questions.size, profile.profile_answers.size
  end
end
