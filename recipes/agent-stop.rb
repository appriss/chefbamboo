# Stop the bamboo agent
execute "start bamboo agent" do
  command "#{node[:bamboo][:agent][:home]}/bamboo-agent-home/bin/bamboo-agent.sh stop"
  user node[:bamboo][:run_as]
  action :run
end