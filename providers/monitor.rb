# Creates the proper yaml file in /etc/dd-agent/conf.d/

# Defined since Chef 11
use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :add do
  Chef::Log.debug "Adding monitoring for #{new_resource.name}"
  template "#{node['datadog']['config_dir']}/conf.d/#{new_resource.name}.yaml" do
    unless node['platform_family'] == 'windows'
      owner 'dd-agent'
      mode 00600
    end
    variables(
      :init_config => new_resource.init_config,
      :instances   => new_resource.instances
    )
    cookbook new_resource.cookbook
    notifies :restart, 'service[datadog-agent]', :delayed if node['datadog']['agent_start']
  end

  service 'datadog-agent' do
    service_name node['datadog']['agent_name']
  end
end

action :remove do
  Chef::Log.debug "Removing #{new_resource.name} from #{node['datadog']['config_dir']}/conf.d/"
  file "#{node['datadog']['config_dir']}/conf.d/#{new_resource.name}.yaml" do
    action :delete
    notifies :restart, 'service[datadog-agent]', :delayed if node['datadog']['agent_start']
  end

  service 'datadog-agent' do
    service_name node['datadog']['agent_name']
  end
end
