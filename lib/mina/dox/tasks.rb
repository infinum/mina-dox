set :dox_version, 'v1'
set :dox_path, -> { "api/#{fetch(:dox_version)}/docs" }

namespace :dox do
  task :generate do
    ensure!(:dox_version)
    run :local do
      command "RAILS_ENV=test bundle exec rake 'dox:html[#{fetch(:dox_version)}, #{fetch(:dox_path)}, https://#{fetch(:domain)}]'"
    end
  end

  task publish: :generate do
    ensure!(:dox_path)
    run(:remote) do
      command "mkdir -p #{fetch(:current_path)}/public/#{fetch(:dox_path)}"
    end

    run(:local) do
      local_path = "public/#{fetch(:dox_path)}/index.html"
      remote_path = "#{fetch(:user)}@#{fetch(:domain)}:#{fetch(:current_path)}/public/#{fetch(:dox_path)}"
      command "scp -P #{fetch(:port)} #{local_path} #{remote_path}"
    end
  end
end
