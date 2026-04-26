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

  test "answer_for returns the profile_answer for a given question" do
    profile = profiles(:one)
    assert_equal "Mountain biking", profile.answer_for(profile_questions(:sport)).answer
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

  test "current_phase returns :photo when no photo attached" do
    assert_equal :photo, profiles(:one).current_phase
  end

  test "current_phase returns :question when photo attached but any answer blank" do
    profile = profiles(:two)
    attach_test_photo(profile)
    assert_equal :question, profile.reload.current_phase
  end

  test "current_phase returns :finalize when all answers present but not selected" do
    profile = profiles(:one)
    attach_test_photo(profile)
    assert_equal :finalize, profile.reload.current_phase
  end

  test "current_phase returns :complete when selected image + name present" do
    profile = profiles(:one)
    attach_test_photo(profile)
    answer = profile.profile_answers.first
    ig = answer.create_image_generation!(animal: "fox", prompt: "stub")
    ig.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test.png")),
      filename: "gen.png",
      content_type: "image/png"
    )
    profile.update!(selected_image_generation: ig)
    assert_equal :complete, profile.reload.current_phase
  end

  test "next_unanswered_question returns the first active question missing an answer" do
    profile = profiles(:two)
    missing = profile.next_unanswered_question
    assert_equal profile_questions(:shop), missing
  end

  test "selected_image must belong to this profile" do
    profile = profiles(:one)
    other_answer = profiles(:two).profile_answers.first
    ig = other_answer.create_image_generation!(animal: "fox", prompt: "stub")
    ig.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test.png")),
      filename: "gen.png",
      content_type: "image/png"
    )
    profile.selected_image_generation = ig
    refute profile.valid?
    assert profile.errors[:selected_image_generation].any?
  end

  test "selected_image must have attached image" do
    profile = profiles(:one)
    answer = profile.profile_answers.first
    ig = answer.create_image_generation!(animal: "fox", prompt: "stub")
    profile.selected_image_generation = ig
    refute profile.valid?
    assert_includes profile.errors[:selected_image_generation].join, "still generating"
  end

  private

  def attach_test_photo(profile)
    profile.reference_photo.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test.png")),
      filename: "test.png",
      content_type: "image/png"
    )
  end
end
