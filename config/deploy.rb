require 'rvm/capistrano'
require 'bundler/capistrano'

set :rvm_type, :user

set :application, 'strano-production'
set :rvm_ruby_string, "1.9.3"

set :scm, :git
set :repository,  'https://github.com/denis-dedov/strano.git'
set :branch, :master

set :user, 'ubuntu'
set :use_sudo, false
set :domain, 'strano.isarops.com'
server domain, :app, :web

set :host, domain

set :deploy_to, '/home/ubuntu/strano-production'
set :deploy_via, :remote_cache
set :keep_releases, 3

before 'deploy:assets:precompile', 'deploy:configure'
after 'deploy:assets:precompile', 'deploy:make_release_symlinks_in_web_directory'
after 'deploy', 'deploy:sidekiq:restart'
after 'deploy', 'deploy:apache:restart'
after 'deploy', 'deploy:make_symlink_to_repos'

namespace :deploy do
  task :configure do
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/config/strano.yml #{release_path}/config/strano.yml"
  end

  task :make_release_symlinks_in_web_directory do
    run 'if [ -L /var/www/strano/public ]; then rm /var/www/strano/public; fi'
    run "ln -s #{release_path}/public /var/www/strano/public"
    run 'if [ -L /var/www/strano/strano-production ]; then rm /var/www/strano/strano-production; fi'
    run "ln -s #{release_path} /var/www/strano/strano-production"
  end

  task :make_symlink_to_repos do
    run "if [ -d #{release_path}/vendor/repos ]; then rm #{release_path}/vendor/repos; fi"
    run "ln -s #{deploy_to}/shared/repos #{release_path}/vendor/repos"
  end

  namespace :apache do
    task :restart do
      run 'sudo service apache2 restart'
    end
  end

  namespace :sidekiq do
    task :restart do
      run "if [ -f #{deploy_to}/shared/tmp/pids/sidekiq.pid ] && ps -p `cat #{deploy_to}/shared/tmp/pids/sidekiq.pid`; then kill -QUIT `cat #{deploy_to}/shared/tmp/pids/sidekiq.pid`; fi"
      run "cd #{release_path} && bundle exec sidekiq start -d -L #{deploy_to}/shared/log/sidekiq.log -P #{deploy_to}/shared/tmp/pids/sidekiq.pid -c 1"
    end
  end
end

#after "deploy:restart", "deploy:cleanup"

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
