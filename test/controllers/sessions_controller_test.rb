require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new renders login form with email field" do
    get new_session_path
    assert_response :success
    assert_select "input[name=email]"
  end

  test "create with known email sends magic link and shows confirmation" do
    assert_enqueued_email_with VillagerMailer, :login_link, args: [villagers(:one)] do
      post session_path, params: {email: villagers(:one).email}
    end
    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "login link", response.body
  end

  test "create with unknown email shows same message without sending" do
    assert_no_enqueued_emails do
      post session_path, params: {email: "nobody@example.com"}
    end
    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "login link", response.body
  end

  test "create is case-insensitive" do
    assert_enqueued_email_with VillagerMailer, :login_link, args: [villagers(:one)] do
      post session_path, params: {email: villagers(:one).email.upcase}
    end
  end

  test "GET callback renders confirmation form without signing in" do
    villager = villagers(:one)
    token = villager.generate_token_for(:login)
    get callback_session_path(token: token)
    assert_response :success
    assert_select "form[action='#{callback_session_path}']"
    assert_select "input[name=token][value='#{token}']", visible: :all
    # Not signed in yet
    assert_nil session[:villager_id]
  end

  test "POST callback with valid token signs in" do
    villager = villagers(:one)
    token = villager.generate_token_for(:login)
    post callback_session_path, params: {token: token}
    assert_redirected_to edit_profile_path
    follow_redirect!
    assert_response :success
  end

  test "POST callback with invalid token rejects" do
    post callback_session_path, params: {token: "bogus"}
    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "Invalid or expired", response.body
  end

  test "destroy signs out" do
    sign_in_villager(villagers(:one))
    delete session_path
    assert_redirected_to root_path

    get edit_profile_path
    assert_redirected_to new_session_path
  end

  private

  def sign_in_villager(villager)
    post callback_session_path, params: {token: villager.generate_token_for(:login)}
  end
end
