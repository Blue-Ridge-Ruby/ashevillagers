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

  test "new requires login" do
    get new_profile_path
    assert_redirected_to new_session_path
  end

  # -- Logged-in villager --

  test "edit shows form for logged-in villager with profile" do
    sign_in_villager(villagers(:one))
    get edit_profile_path
    assert_response :success
    assert_select "input[name='profile[first_name]']"
  end

  test "new redirects to edit when profile exists" do
    sign_in_villager(villagers(:one))
    get new_profile_path
    assert_redirected_to edit_profile_path
  end

  test "new shows form for villager without profile" do
    sign_in_villager(villagers(:unlinked))
    villagers(:unlinked).profile&.destroy
    get new_profile_path
    assert_response :success
  end

  test "new prefills name from villager" do
    villager = villagers(:unlinked)
    villager.profile&.destroy
    sign_in_villager(villager)
    get new_profile_path
    assert_select "input[name='profile[first_name]'][value='Pat']"
  end

  test "create builds a profile for the villager" do
    villager = villagers(:unlinked)
    villager.profile&.destroy
    sign_in_villager(villager)

    assert_difference "Profile.count", 1 do
      post profile_path, params: {
        profile: {first_name: "Pat", last_name: "Taylor"}
      }
    end
    assert_redirected_to edit_profile_path
  end

  test "update changes profile name" do
    sign_in_villager(villagers(:one))
    patch profile_path, params: {
      profile: {first_name: "Janet"}
    }
    assert_redirected_to edit_profile_path
    assert_equal "Janet", profiles(:one).reload.first_name
  end

  test "update saves answers via nested attributes" do
    sign_in_villager(villagers(:one))
    answer = profile_answers(:one_sport)
    patch profile_path, params: {
      profile: {
        profile_answers_attributes: [
          {id: answer.id, profile_question_id: answer.profile_question_id, answer: "Kayaking"}
        ]
      }
    }
    assert_redirected_to edit_profile_path
    assert_equal "Kayaking", answer.reload.answer
  end

  test "update with invalid photo renders edit" do
    sign_in_villager(villagers(:one))
    patch profile_path, params: {
      profile: {photo: fixture_file_upload("test.txt", "text/plain")}
    }
    assert_response :unprocessable_entity
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
    assert_select "a[href='#{new_profile_path}']", text: "Create Profile"
  end

  private

  def sign_in_villager(villager)
    post callback_session_path, params: {token: villager.generate_token_for(:login)}
  end
end
