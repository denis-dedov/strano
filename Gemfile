source 'http://rubygems.org'

gem 'rails', '~>3.2.11'
gem 'mysql2'
gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
  gem 'jquery-rails', '2.0.2'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails', '2.0.5'
end

gem 'sidekiq', '2.12'
gem 'slim'
gem 'omniauth-github'
gem 'yajl-ruby'
gem 'faraday'
gem 'faraday-stack'
gem 'faraday_middleware'
gem 'capistrano-ext'
gem 'capistrano_colors'
gem 'capistrano-campfire'
gem 'capistrano_rsync_with_remote_cache'
gem 'rvm-capistrano'
gem 'grit'
gem 'dotiw'
gem 'inherited_resources'
gem 'kaminari'
gem 'permanent_records'
gem 'simple_form', '~> 2'
gem 'open4'
gem 'ansible'
gem 'brightbox'
gem 'git'
gem 'pivotal-tracker'

# While these are not needed by Strano itself, without them installed, any project
# that requires them will die when Strano tries to run a cap task. By using
# :require => nil, these don't get required/loaded into Strano, but are installed
# for projects to use if needed.
gem 'delayed_job', :require => nil
gem 'whenever', :require => nil
gem 'airbrake', :require => nil
gem 'newrelic_rpm', :require => nil

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'marked'
  gem 'ffaker'
end

group :development do
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'debugger'
  gem 'thin'
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'vcr', '~> 2'
  gem 'webmock'
  gem "fakefs", :require => "fakefs/safe"
end
