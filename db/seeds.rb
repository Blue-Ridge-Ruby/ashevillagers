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
    llm_prompt: <<~PROMPT.squish,
      The user will name a sport. Respond with the kind of athelete who does that sport
      in no more than three words, title-case. (e.g., "Swimmer" "Mountain Biker"
      "Pickleball Player") If the named sport doesn't make sense, get
      creative or euphemistic in your interpretation or choose a kind of athelete arbitrarily.
      Always provide a kind of athelete and keep it G or PG-rated. Do not use trademarked names.
      Respond with ONLY the kind of athelete, nothing else.
    PROMPT
    position: 1,
    active: true
  }, {
    question: "If you had a non-tech job in retirement, what would it be?",
    llm_prompt: <<~PROMPT.squish,
      The user will provide a job. Respond with a short version of that job title in
      no more than three words, title-case. (e.g., "Tea Shop Owner"
      "Accountant" "Donut Artistan") If the named job doesn't make sense, get
      creative or euphemistic in your interpretation or choose a title arbitrarily.
      Always provide a job title and keep it G or PG-rated. Do not use trademarked names.
      Respond with ONLY the job title, nothing else.
    PROMPT
    position: 2,
    active: true
  }, {
    question: "If you owned a shop, what kind would it be?",
    llm_prompt: <<~PROMPT.squish,
      Give a short description or title in no more than three words of someone
      who owns or operates the kind of shop the user names. (e.g., "Tea Shop Owner"
      "Accountant" "Donut Artistan") If the named shop type doesn't make sense, get
      creative or euphemistic in your interpretation or choose a title arbitrarily.
      Always provide a title and keep it G or PG-rated. Do not use trademarked names.
      Respond with ONLY the title/description, nothing else.
    PROMPT
    position: 3
  }, {
    question: "If you could get a master's degree in a new field, what would it be?",
    llm_prompt: <<~PROMPT.squish,
      Give a short job description or title in no more than three words of someone
      with an advanced degree in the field of study the user names. (e.g., "Doctor"
      "Paleontologist" "Arborist") If the named field doesn't make sense, get creative
      or euphemistic in your interpretation or choose an occupation arbitrarily.
      Always provide an occupation and keep it G or PG-rated.
      Respond with ONLY the title/occupation, nothing else.
    PROMPT
    position: 4,
    active: true
  }, {
    question: "What's an art or craft you do now or would like to learn?",
    llm_prompt: <<~PROMPT.squish,
      Give a short job description or title in no more than three words of someone
      engaged in the art or craft the user names. (e.g., "Sculptor" "Fiber Artist"
      "Carpenter") If the named craft doesn't make sense, get creative or
      euphemistic in your interpretation or choose a type of artist arbitrarily.
      Always provide a type of craftsperson or artist and keep it G or PG-rated.
      Respond with ONLY the title, nothing else.
    PROMPT
    position: 5,
    active: false
  }
].each do |attrs|
  ProfileQuestion.find_or_create_by!(question: attrs[:question]) do |pq|
    pq.position = attrs[:position]
    pq.llm_prompt = attrs[:llm_prompt]
    pq.active = attrs[:active]
  end
end
