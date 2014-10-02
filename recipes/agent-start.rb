# Start the bamboo agent
execute "stop bamboo agent" do
  command "#{node[:bamboo][:agent][:home]}/bamboo-agent-home/bin/bamboo-agent.sh start"
  user node[:bamboo][:run_as]
  action :run
end