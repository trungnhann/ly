source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

gem 'grpc'
gem 'grpc-tools'
gem 'sassc-rails'
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'

# Plus integrations with:
gem 'cancancan'
gem 'draper'
gem 'pundit'

gem 'bootsnap', require: false

gem 'kamal', require: false

gem 'thruster', require: false

gem 'rack-cors'

gem 'devise'
gem 'devise-jwt'
gem 'jsonapi-serializer'

gem 'aws-sdk-s3'
gem 'pagy'
gem 'ransack'

gem 'mongoid', '~> 9.0'
gem 'mongoid-paperclip', require: 'mongoid_paperclip'
gem 'mongoid-slug'
gem 'solid_queue_dashboard', '~> 0.2.0', github: 'zhuravel/solid-queue-dashboard', branch: 'patch-1'

# HTTP client
gem 'httparty'
gem 'roo'

group :development, :test do
  gem 'annotate', github: 'andynu/annotate_models', branch: 'rails-8-0'
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  gem 'brakeman', require: false

  gem 'rubocop-rails-omakase', require: false

  gem 'dotenv-rails'
end
