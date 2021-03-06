# If SSL agent support is enabled
if node[:bamboo][:agent][:ssl][:enable]
  # Create bamboo environment profile
  file "/etc/profile.d/bamboo.sh" do
    content "export SSL_OPTS=\"-Djavax.net.ssl.keyStore=#{node[:bamboo][:home]}/bamboo_server.ks -Djavax.net.ssl.keyStorePassword=#{node[:bamboo][:agent][:ssl][:keystore_password]}\";export JAVA_OPTS=$SSL_OPTS $JAVA_OPTS;"
    owner "root"
    group "root"
    mode "0644"
    action :create
  end

  execute "run profile" do
    command "source /etc/profile.d/bamboo.sh"
    action :run
  end
end

