node[:deploy].each do |application, deploy|
  if deploy.is_a?(Hash) && deploy['shoryuken']
    shoryuken_config = deploy['shoryuken']
    deploy_dir = ::File.join('/', 'srv', 'www', application)
    release_path = ::File.join(deploy_dir, 'current')
    pidfile_path = ::File.join(deploy_dir, 'shared', 'pids', 'shoryuken.pid')
    logfile_path = ::File.join(deploy_dir, 'shared', 'log', 'shoryuken.log')
    config_path = ::File.join(release_path, 'config', 'shoryuken.yml')
    rails_env = deploy['global']['environment']
    start_command = shoryuken_config['start_command'] || "/usr/local/bin/bundle exec shoryuken -R --pidfile '#{pidfile_path}' --logfile '#{logfile_path}' -C '#{config_path}'"
    app = data_bag_item("aws_opsworks_app", application)
    env = app['environment'] || {}

=begin
    template "setup shoryuken.conf" do
      path "/etc/init/shoryuken-#{application}.conf"
      source "shoryuken.conf.erb"
      owner "root"
      group "root"
      mode 0644
      variables({
        app_name: application,
        user: node['deployer']['user'],
        group: 'www-data',
        release_path: release_path,
        rails_env: rails_env,
        start_command: start_command,
        env: env,
      })
    end

    service "shoryuken-#{application}" do
      provider Chef::Provider::Service::Upstart
      supports stop: true, start: true, restart: true, status: true
    end
=end

    template "setup shoryuken.service" do
      path "/lib/systemd/system/shoryuken-#{application}.service"
      source "shoryuken.service.erb"
      owner "root"
      group "root"
      mode 0644
      variables({
        app_name: application,
        user: node['deployer']['user'],
        group: 'www-data',
        release_path: release_path,
        rails_env: rails_env,
        start_command: start_command,
        env: env,
      })
      notifies :run, 'execute[systemctl daemon-reload]', :immediately
    end

    service "shoryuken-#{application}" do
      provider Chef::Provider::Service::Systemd
      supports stop: true, start: true, restart: true, status: true
      action [:enable, :start]
    end

    execute 'systemctl daemon-reload' do
      command 'systemctl daemon-reload'
      action :nothing
    end

    # always restart shoryuken on deploy since we assume the code must need to be reloaded
    bash 'restart_shoryuken' do
      code "echo noop"
      notifies :restart, "service[shoryuken-#{application}]"
    end
  end
end
