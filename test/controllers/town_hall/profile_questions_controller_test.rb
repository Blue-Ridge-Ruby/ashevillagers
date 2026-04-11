require "test_helper"

class TownHall::ProfileQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post town_hall_session_path, params: {email: stewards(:one).email, password: "password"}
  end

  test "index requires authentication" do
    delete town_hall_session_path
    get town_hall_profile_questions_path
    assert_redirected_to new_town_hall_session_path
  end

  test "index lists questions" do
    get town_hall_profile_questions_path
    assert_response :success
    assert_select "table"
    assert_select "td", text: /sport/i
  end

  test "new" do
    get new_town_hall_profile_question_path
    assert_response :success
  end

  test "create" do
    assert_difference "ProfileQuestion.count", 1 do
      post town_hall_profile_questions_path, params: {
        profile_question: {question: "What's your favorite book?", position: 5, active: true}
      }
    end
    assert_redirected_to town_hall_profile_questions_path
  end

  test "create with invalid data" do
    assert_no_difference "ProfileQuestion.count" do
      post town_hall_profile_questions_path, params: {
        profile_question: {question: "", position: 5}
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit" do
    get edit_town_hall_profile_question_path(profile_questions(:sport))
    assert_response :success
  end

  test "update" do
    pq = profile_questions(:sport)
    patch town_hall_profile_question_path(pq), params: {
      profile_question: {question: "What sport do you play?", llm_prompt: "Generate a sporty character"}
    }
    assert_redirected_to town_hall_profile_questions_path
    pq.reload
    assert_equal "What sport do you play?", pq.question
    assert_equal "Generate a sporty character", pq.llm_prompt
  end

  test "update with invalid data" do
    patch town_hall_profile_question_path(profile_questions(:sport)), params: {
      profile_question: {question: ""}
    }
    assert_response :unprocessable_entity
  end

  test "toggle active" do
    pq = profile_questions(:sport)
    assert pq.active?
    patch town_hall_profile_question_path(pq), params: {
      profile_question: {active: false}
    }
    assert_redirected_to town_hall_profile_questions_path
    refute pq.reload.active?
  end
end
