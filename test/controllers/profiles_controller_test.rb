require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  # -- Public pages --

  test "index renders successfully" do
    get root_path
    assert_response :success
    assert_select "h1", text: /Ashevillagers/
  end

  test "index shows profile cards" do
    get root_path
    assert_response :success
    assert_select "a[href*='#{profiles(:one).id}']"
  end

  test "show renders a profile" do
    profile = profiles(:one)
    get public_profile_path(profile)
    assert_response :success
    assert_select "h1", text: /Jane/
  end

  # -- Auth required --

  test "edit requires login" do
    get edit_profile_path
    assert_redirected_to new_session_path
  end

  # -- edit auto-creates profile when missing --

  test "edit builds a profile using villager's name when none exists" do
    villager = villagers(:unlinked)
    villager.profile&.destroy
    sign_in_villager(villager)

    assert_difference "Profile.count", 1 do
      get edit_profile_path
    end
    assert_response :success
    assert_equal "Pat", villager.reload.profile.first_name
  end

  # -- edit phase dispatching --

  test "edit renders phase_photo when no photo attached" do
    sign_in_villager(villagers(:one))
    get edit_profile_path
    assert_response :success
    assert_select "input[type=file][name='profile[reference_photo]']"
  end

  test "edit renders phase_question when photo present but answers missing" do
    profile = profiles(:two)
    attach_photo(profile)
    sign_in_villager(villagers(:two))
    get edit_profile_path
    assert_response :success
    assert_select "input[name='profile_answer[answer]']"
  end

  test "edit renders phase_finalize when all answers present" do
    profile = profiles(:one)
    # one_sport/retirement/shop/degree cover all 4 active questions
    attach_photo(profile)
    sign_in_villager(villagers(:one))
    get edit_profile_path
    assert_response :success
    assert_select "input[name='profile[first_name]']"
    assert_select "input[name='profile[selected_image_generation_id]']", false # no image_generations yet
  end

  test "edit renders phase_complete when finalized" do
    profile = profiles(:one)
    attach_photo(profile)
    ig = create_image_generation(profile.profile_answers.first)
    profile.update!(selected_image_generation: ig)

    sign_in_villager(villagers(:one))
    get edit_profile_path
    assert_response :success
    assert_select "a", text: /View public profile/
  end

  # -- update: photo branch --

  test "update with photo attaches photo and redirects" do
    sign_in_villager(villagers(:one))
    patch profile_path, params: {
      profile: {reference_photo: fixture_file_upload("test.png", "image/png")}
    }
    assert_redirected_to edit_profile_path
    assert profiles(:one).reload.reference_photo.attached?
  end

  test "update with invalid photo renders edit" do
    sign_in_villager(villagers(:one))
    patch profile_path, params: {
      profile: {reference_photo: fixture_file_upload("test.txt", "text/plain")}
    }
    assert_response :unprocessable_entity
  end

  # -- update: finalize branch --

  test "update with finalize params changes name and selection" do
    profile = profiles(:one)
    attach_photo(profile)
    ig = create_image_generation(profile.profile_answers.first)

    sign_in_villager(villagers(:one))
    patch profile_path, params: {
      profile: {first_name: "Janet", last_name: "Doe", selected_image_generation_id: ig.id}
    }
    assert_redirected_to edit_profile_path
    assert_equal "Janet", profile.reload.first_name
    assert_equal ig, profile.selected_image_generation
  end

  test "update rejects selecting another profile's image_generation" do
    profile = profiles(:one)
    attach_photo(profile)
    other_ig = create_image_generation(profiles(:two).profile_answers.first)

    sign_in_villager(villagers(:one))
    patch profile_path, params: {
      profile: {first_name: "Jane", last_name: "Doe", selected_image_generation_id: other_ig.id}
    }
    assert_response :unprocessable_entity
    assert_nil profile.reload.selected_image_generation_id
  end

  # -- Header button --

  test "header shows Login when not signed in" do
    get root_path
    assert_select "a[href='#{new_session_path}']", text: "Login"
  end

  test "header shows Manage when signed in with profile" do
    sign_in_villager(villagers(:one))
    get root_path
    assert_select "a[href='#{edit_profile_path}']", text: "Manage"
  end

  test "header shows Create Profile when signed in without profile" do
    villager = villagers(:unlinked)
    villager.profile&.destroy
    sign_in_villager(villager)
    get root_path
    assert_select "a[href='#{edit_profile_path}']", text: "Create Profile"
  end

  private

  def sign_in_villager(villager)
    post callback_session_path, params: {token: villager.generate_token_for(:login)}
  end

  def attach_photo(profile)
    profile.reference_photo.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test.png")),
      filename: "test.png",
      content_type: "image/png"
    )
  end

  def create_image_generation(profile_answer)
    profile_answer.update_column(:job_title, "Cyclist")
    ig = profile_answer.create_image_generation!(animal: "fox", prompt: "stub")
    ig.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test.png")),
      filename: "gen.png",
      content_type: "image/png"
    )
    ig
  end
end
