# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Rails version from environment or default
rails_version = ENV.fetch("RAILS_VERSION", "8.0")

gem "rails", "~> #{rails_version}.0"

group :development, :test do
  gem "rspec-rails", "~> 6.0"
  gem "capybara", "~> 3.39"
  gem "selenium-webdriver", "~> 4.10"
  gem "puma", "~> 6.0"
  gem "sqlite3", ">= 1.6"

  # Code quality
  gem "rubocop", "~> 1.50", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false

  # Debugging
  gem "debug", require: false
end
