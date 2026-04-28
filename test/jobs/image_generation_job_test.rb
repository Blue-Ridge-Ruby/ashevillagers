require "test_helper"

class ImageGenerationJobTest < ActiveJob::TestCase
  test "calls ensure_and_crop_image! and broadcasts replace" do
    answer = profile_answers(:one_sport)
    ig = answer.create_image_generation!(animal: "fox", prompt: "stub")

    ensure_and_crop_called = false
    broadcast_called_with = nil

    ig.define_singleton_method(:ensure_and_crop_image!) { ensure_and_crop_called = true }
    ig.define_singleton_method(:broadcast_replace_to) do |*args, **opts|
      broadcast_called_with = {args: args, opts: opts}
    end

    ImageGenerationJob.perform_now(ig)

    assert ensure_and_crop_called
    assert_equal [ig.profile], broadcast_called_with[:args]
    assert_equal ActionView::RecordIdentifier.dom_id(ig), broadcast_called_with[:opts][:target]
    assert_equal "profiles/image_generation", broadcast_called_with[:opts][:partial]
  end
end
