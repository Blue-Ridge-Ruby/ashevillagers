# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Steward.find_or_create_by!(email: "mayor@blueridgeruby.com") do |s|
  s.first_name = "Jeremy"
  s.last_name = "Smith"
  s.password = "password"
  s.password_confirmation = "password"
end

[
  {
    question: "What new sport would you like to pick up?",
    llm_prompt: "You are an illustrator of children's books commissioned to create anthropomorphic animal illustrations in the style of Richard Scarry. Based on the user-provided profile image and the user-provided sport below, please create an illustration of the user in the style of Richard Scarry as a %s athlete from Asheville, North Carolina. Please make sure you can see every part of the animal's body, but don't include many additional objects on or around the figure. Make sure that the illustration is on a white background and don't put any words on the illustration.",
    position: 1
  }, {
    question: "If you had a non-tech job in retirement, what would it be?",
    llm_prompt: "You are an illustrator of children's books commissioned to create anthropomorphic animal illustrations in the style of Richard Scarry. Based on the user-provided profile image and the user-provided job below, please create an illustration of the user in the style of Richard Scarry as a %s from Asheville, North Carolina working that job. Please make sure you can see every part of the animal's body, but don't include many additional objects on or around the figure. Make sure that the illustration is on a white background and don't put any words on the illustration.",
    position: 2
  }, {
    question: "If you owned a shop, what kind would it be?",
    llm_prompt: "You are an illustrator of children's books commissioned to create anthropomorphic animal illustrations in the style of Richard Scarry. Based on the user-provided profile image and the user-provided kind of shop below, please create an illustration of the user in the style of Richard Scarry as a %s from Asheville, North Carolina as the proprietor of that shop. Please make sure you can see every part of the animal's body, but don't include many additional objects on or around the figure. Make sure that the illustration is on a white background and don't put any words on the illustration.",
    position: 3
  }, {
    question: "If you could get a master's degree in a new field, what would it be?",
    llm_prompt: "You are an illustrator of children's books commissioned to create anthropomorphic animal illustrations in the style of Richard Scarry. Based on the user-provided profile image and the user-provided field of study below, please create an illustration of the user in the style of Richard Scarry as a %s from Asheville, North Carolina doing something that makes sense for having an advanced degree in the field of study. Please make sure you can see every part of the animal's body, but don't include many additional objects on or around the figure. Make sure that the illustration is on a white background and don't put any words on the illustration.",
    position: 4
  }
].each do |attrs|
  ProfileQuestion.find_or_create_by!(question: attrs[:question]) do |pq|
    pq.position = attrs[:position]
    pq.llm_prompt = attrs[:llm_prompt]
    pq.active = true
  end
end
