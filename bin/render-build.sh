#!/usr/bin/env bash
# exit on error
set -o errexit

bundle config set --local force_ruby_platform true
bundle install
# If you're using a Free instance type, you need to
# perform database migrations in the build command.
# Uncomment the following line:

npm install
npm run build:css

# Run migrations for all databases
bundle exec rails db:migrate
bundle exec rails db:migrate:cache
bundle exec rails db:migrate:queue
bundle exec rails db:migrate:cable
bundle exec rails db:seed