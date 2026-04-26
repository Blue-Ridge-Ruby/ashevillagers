require "test_helper"

class ProfileAnswersControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "update requires login" do
    answer = profile_answers(:one_sport)
    patch profile_profile_answer_path(answer), params: {profile_answer: {answer: "hello"}}
    assert_redirected_to new_session_path
  end

  test "update saves the answer, creates image_generation, and enqueues the job" do
    sign_in_villager(villagers(:two))
    # Two has a sport answer but no image_generation yet
    answer = profile_answers(:two_sport)
    refute answer.image_generation.present?

    assert_enqueued_with(job: ImageGenerationJob) do
      patch profile_profile_answer_path(answer), params: {profile_answer: {answer: "Surfing"}}
    end
    assert_redirected_to edit_profile_path
    assert_equal "Surfing", answer.reload.answer
    assert answer.image_generation.present?
  end

  test "update does not re-create image_generation if one already exists" do
    sign_in_villager(villagers(:one))
    answer = profile_answers(:one_sport)
    existing = answer.create_image_generation!(animal: "fox", prompt: "stub")

    patch profile_profile_answer_path(answer), params: {profile_answer: {answer: "Climbing"}}
    assert_redirected_to edit_profile_path
    assert_equal existing, answer.reload.image_generation
  end

  test "update with blank answer re-renders edit" do
    sign_in_villager(villagers(:two))
    answer = profile_answers(:two_sport)
    profiles(:two).reference_photo.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test.png")),
      filename: "test.png",
      content_type: "image/png"
    )

    patch profile_profile_answer_path(answer), params: {profile_answer: {answer: ""}}
    assert_response :unprocessable_entity
  end

  test "update cannot touch another profile's answer" do
    sign_in_villager(villagers(:one))
    other_answer = profile_answers(:two_sport)
    patch profile_profile_answer_path(other_answer), params: {profile_answer: {answer: "Hacked"}}
    assert_response :not_found
    assert_equal "Rock climbing", other_answer.reload.answer
  end

  private

  def sign_in_villager(villager)
    post callback_session_path, params: {token: villager.generate_token_for(:login)}
  end
end
