class ImageGenerationJob < ApplicationJob
  queue_as :default

  def perform(image_generation)
    image_generation.ensure_image!
    image_generation.ensure_cropped!
    image_generation.broadcast_replace_to(
      image_generation.profile,
      target: ActionView::RecordIdentifier.dom_id(image_generation),
      partial: "profiles/image_generation",
      locals: {image_generation: image_generation}
    )
  end
end
