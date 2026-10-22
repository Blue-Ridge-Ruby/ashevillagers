class ImageGenerationJob < ApplicationJob
  queue_as :default

  retry_on Faraday::ConnectionFailed

  rescue_from(RubyLLM::Error) do |error|
    raise error unless error.message.to_s.match?(/safety system/i)
    raise error if executions >= 5
    retry_job wait: 3.seconds
  end

  def perform(image_generation)
    image_generation.ensure_and_crop_image!
    image_generation.broadcast_replace_to(
      image_generation.profile,
      target: ActionView::RecordIdentifier.dom_id(image_generation),
      partial: "profiles/image_generation",
      locals: {image_generation: image_generation}
    )
  end
end
