source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'rack-cors'
gem 'bcrypt'
gem 'rails', '~> 7.0'
gem 'puma', '~> 3.11'
gem 'uglifier', '>= 1.3.0'
gem 'execjs'
gem 'font-awesome-sass', '>= 5.15.1'
gem 'jbuilder', '~> 2.5'
gem 'pg'
gem 'will_paginate'
gem "sprockets-rails"
gem 'dotenv-rails'
gem 'jwt'
gem 'hotwire-rails'
gem 'turbo-rails'
gem 'stimulus-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

