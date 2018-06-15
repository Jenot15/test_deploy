server 'calculator-web-1.production.devguru.co', user: 'deploy', roles: %w[app web]
server 'calculator-web-2.production.devguru.co', user: 'deploy', roles: %w[app web]
set :branch, 'production'

namespace :deploy do
  def compose(cmd, role)
    "-p #{fetch(:application)} -f docker-compose-#{fetch(:stage)}.yml #{cmd}"
  end

  after :updated, 'terrafromtest:deploy' do
    ## build image on all nodes
    on roles(:web), in: :parallel do
      within release_path do
        execute :"docker-compose", compose("build", "web")
      end
    end

    ## restart web containers
    on roles(:web), in: :parallel do
      within release_path do
        execute :"docker-compose", compose("up -d --force-recreate", "web")
      end
    end
  end
end
