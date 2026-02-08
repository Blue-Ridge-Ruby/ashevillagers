require "test_helper"

class StewardMailerTest < ActionMailer::TestCase
  test "password_reset" do
    steward = stewards(:one)
    mail = StewardMailer.password_reset(steward)

    assert_equal "Reset your password", mail.subject
    assert_equal [ steward.email ], mail.to
    assert_match "Reset my password", mail.body.encoded
    assert_match "1 hour", mail.body.encoded
  end
end
