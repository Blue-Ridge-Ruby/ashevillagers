source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Falcon async web server [https://github.com/socketry/falcon]
gem "falcon"
gem "falcon-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Vite for asset bundling [https://vite-ruby.netlify.app/]
gem "vite_rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache and Action Cable
gem "solid_cache"
gem "solid_cable"

# Use async-job as the Active Job queue adapter, running in-process under Falcon
gem "async-job-adapter-active_job"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

gem "propshaft"

# Tito API client (local development copy)
# gem "tito_ruby", path: "../tito_ruby"
gem "tito_ruby"

# Send mail with postmark
gem "postmark-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Ruby style linting [https://github.com/standardrb/standard]
  gem "standard", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Preview mail in the browser instead of sending [https://github.com/ryanb/letter_opener]
  gem "letter_opener"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

# .paint(with:) support comes in 1.15, not yet released as of now. Pinned at a known-working commit on main.
gem "ruby_llm", github: "crmne/ruby_llm", ref: "4371a1b250a2960d8891548e9fb4633de39bcd40"
