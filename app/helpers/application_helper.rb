module ApplicationHelper
  # Direct signed disk service path for an attachment/variant. Works in jobs too (no request needed).
  def signed_blob_path(representation)
    url = ActiveStorage::Current.set(url_options: {host: "localhost"}) { representation.url }
    URI(url).request_uri
  end
end
