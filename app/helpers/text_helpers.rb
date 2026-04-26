module TextHelpers
  def indefinite(str)
    str.start_with?(/[aeiouAEIOU]/) ? "an #{str}" : "a #{str}"
  end
end
