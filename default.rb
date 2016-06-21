#
# Cookbook Name::tomcat
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

tc_install_dir = node[tomcat']['install_dir']
tarball_file = node[tomcat']['tarball_name']
host_name = node['hostname']
servers = node[tomcat'][host_name]['instances']
host_cluster_name = node[tomcat'][host_name]['host_cluster_name'].to_s.empty?? node[tomcat']['host_cluster_name'] : node[tomcat'][host_name]['host_cluster_name']
host_cluster_member_name = node[tomcat'][host_name]['host_cluster_member_name'].to_s.empty?? node[tomcat']['host_cluster_member_name'] : node[tomcat'][host_name]['host_cluster_member_name']
ldap_bind_user = node[tomcat']['ldap_bind_user']
ldap_bind_key = node[tomcat']['ldap_bind_key']
ssl_cert_file = node[tomcat'][host_name]['ssl_cert_file'].to_s.empty?? node[tomcat']['ssl_cert_file'] : node[tomcat'][host_name]['ssl_cert_file']
ssl_cert_key_file = node[tomcat'][host_name]['ssl_cert_key_file'].to_s.empty?? node[tomcat']['ssl_cert_key_file'] : node[tomcat'][host_name]['ssl_cert_key_file']

directory tc_install_dir do
  owner '#######'
  group '#######'
  mode '0755'
  action :create
end

directory "#{tc_install_dir}/servers" do
  owner '#######'
  group '#######'
  mode '0755'
  recursive true
end

directory "#{tc_install_dir}/conf/httpd" do
  owner '#######'
  group '#######'
  mode '0755'
  recursive true
  action :create
end

cookbook_file "#{tc_install_dir}/conf/servers.conf" do
  action :create_if_missing
  owner '#######'
  group '#######'
  mode '0755'
  source 'servers.conf'
end


cookbook_file "#{Chef::Config[:file_cache_path]}/#{tarball_file}" do
  action :create_if_missing
  source tarball_file
  owner '#######'
  group '#######'
  mode '0755'
end

execute 'tar' do
  user '#######'
  group '#######'
  cwd tc_install_dir
  action :run
  command "tar -xvzf #{Chef::Config[:file_cache_path]}/#{tarball_file}"
  not_if { ::File.directory?("#{tc_install_dir}tomcat8/apache") && ::File.directory?("#{tc_install_dir}tomcat8/bin") && 
		   ::File.directory?("#{tc_install_dir}tomcat8/doc-root") && ::File.directory?("#{tc_install_dir}tomcat8/lib") &&  
		   ::File.directory?("#{tc_install_dir}tomcat8/netjets") &&  ::File.directory?("#{tc_install_dir}tomcat8/ssl")}
end


directory "#{tc_install_dir}tomcat8/doc-root/logs" do
  owner '#######'
  group '#######'
  mode '0755'
  recursive true
  action :create
end



template "#{tc_install_dir}/conf/httpd/00-host.conf" do
        source '00-host.conf.erb'
        owner '#######'
        group '#######'
        mode '0755'
        variables({
		    :host_cluster_name => host_cluster_name,
		    :host_cluster_member_name => host_cluster_member_name
  		})
end

template "#{tc_install_dir}/conf/httpd/00-host-secure.conf" do
        source '00-host-secure.conf.erb'
        owner '#######'
        group '#######'
        mode '0755'
        variables({
		    :host_cluster_name => host_cluster_name,
		    :host_cluster_member_name => host_cluster_member_name,
		    :install_dir => tc_install_dir,
		    :ldap_bind_user => ldap_bind_user,
		    :ldap_bind_key => ldap_bind_key,
		    :ssl_cert_file => ssl_cert_file,
		    :ssl_cert_key_file => ssl_cert_key_file
  		})
end

# ruby_block 'crate link file names' do
#   block do
#     node.default[tomcat']['tc8_dir_name'] =::Dir.glob("#{tc_install_dir}tomcat8/apache/tomcat-8.*")
# 	  node.default[tomcat']['tc8_native_dir_name'] =::Dir.glob("#{tc_install_dir}tomcat8/apache/tomcat-native-1.*")
# 	  node.default[tomcat']['mq7'] =::Dir.glob("#{tc_install_dir}tomcat8/lib/ibm/mq-7.*")
# 	  node.default[tomcat']['was7'] =::Dir.glob("#{tc_install_dir}tomcat8/lib/ibm/was7.*")
# 	  node.default[tomcat']['mq_jars'] =::Dir.glob("#{tc_install_dir}tomcat8/lib/ibm/mq7-*/.*")
#   end
# end


# link "#{tc_install_dir}tomcat8/apache/tomcat8" do
#  to node[tomcat']['tc8_dir_name'][0]
# end

link "#{tc_install_dir}tomcat8/apache/tomcat8" do
 to ::Dir.glob("#{tc_install_dir}tomcat8/apache/tomcat-8.*")[0]
end

# link "#{tc_install_dir}tomcat8/apache/tcnative1" do
#   to node[tomcat']['tc8_native_dir_name'][0]
# end

link "#{tc_install_dir}tomcat8/apache/tcnative1" do
  to ::Dir.glob("#{tc_install_dir}tomcat8/apache/tomcat-native-1.*")[0]
end

# link "#{tc_install_dir}tomcat8/lib/ibm/mq7" do
#   to node[tomcat']['mq7'][0]
# end

link "#{tc_install_dir}tomcat8/lib/ibm/mq7" do
  to ::Dir.glob("#{tc_install_dir}tomcat8/lib/ibm/mq-7.*")[0]
end

# link "#{tc_install_dir}tomcat8/lib/ibm/was7" do
#   to node[tomcat']['was7'][0]
# end

link "#{tc_install_dir}tomcat8/lib/ibm/was7" do
  to ::Dir.glob("#{tc_install_dir}tomcat8/lib/ibm/mq-7.*")[0]
end

####### No Apache on poc hence commented ############

# link '#{tc_install_dir}tomcat8/apache/httpd' do
#   to '/etc/httpd'
# end


# link '#{tc_install_dir}tomcat8/doc-root/logs/httpd' do
#   to '/var/log/httpd'
# end


servers.each do |name, attrs|
	  
	  
 
	  server_port_suffix = node[tomcat']['server_port_suffix']
	 environment = attrs['cluster_env']
	  jdk_version= node[tomcat']['java_version']
	  jvm_opts= node['jvm_options']
	  server_host_member_id = attrs['server_host_member_id']
	  server_port_prefix = attrs['server_port_prefix'].to_s.empty?? node[tomcat']['server_port_prefix'] : attrs['server_port_prefix']
	  jvm_size = attrs['jvm_size'].to_s.empty?? node[tomcat']['jvm_size'] : attrs['jvm_size']
	  server_cluster_name = "#{name}-#environment}"
	  server_name = "#{server_cluster_name}#{server_host_member_id}"
	  add_mq7 = attrs['add_mq7']

	  server_dir = "/apps/servers/#{server_name}"
	  server_dirs = ["#{server_dir}", "#{server_dir}/bin", "#{server_dir}/lib",
	  	"#{server_dir}/logs", "#{server_dir}/properties/tomcat", "#{server_dir}/temp", "#{server_dir}/webapps"]
	  # remote_cluster_members = ::Marshal.load(::Marshal.dump(attrs['remote_cluster_members']))
	 # remote_cluster_members = attrs['remote_cluster_members']
	 remote_cluster_members = Hash.new()


	  attrs['remote_cluster_members'].each do |cmname, attributes|
	  		hash_string = "FEDCBA9876543210#{cmname}#{attributes['id']}"
	  		hash_string = hash_string.slice(-16..-1)
	  		hash_string = hash_string.bytes.to_a.join(",")
	  		hash_string = "{#{hash_string}}"
	  		Chef::Log.warn("#############################{hash_string}")
	  		intermidieatHash =  Hash.new()
	  		intermidieatHash ['remote_cluster_member_uid'] = hash_string
	  		remote_cluster_members[cmname] = intermidieatHash
	  		# node.default[tomcat'][host_name]['instances'][name]['remote_cluster_members'][cmname]['remote_cluster_member_uid'] = [hash_string]
		  	# attributes.remote_cluster_member_uid =  hash_string
		end 


      server_dirs.each do |path|
      		directory path do
    		  owner '#######'
    		  group '#######'
              mode '0755'
              recursive true
            end
        end

      remote_directory "#{server_dir}/conf" do
	       source 'conf'
	       files_owner '#######'
	       files_group '#######'
	       files_mode '0755'
	       owner '#######'
	       group '#######'
	       mode '0755'
	     end

      template "#{server_dir}/bin/setenv.sh" do
        source 'setenv.sh.erb'
        owner '#######'
        group '#######'
        mode '0755'
        variables({
		    :server_host => host_cluster_member_name,
		    :server_port_prefix => server_port_prefix,
		    :server_port_suffix => server_port_suffix,
		    environment =>environment,
		    :jdk_version => jdk_version,
		    :jvm_size => jvm_size,
		    :jvm_opts => jvm_opts

  		})
      end

       template "#{server_dir}/properties/tomcat/ldap-credentials.properties" do
        source 'ldap-credentials.properties.erb'
        owner '#######'
        group '#######'
        mode '0755'
        variables({
		    :ldap_bind_user => ldap_bind_user,
		    :ldap_bind_key => ldap_bind_key
  		})
      end

       template "#{server_dir}/properties/tomcat/server.properties" do
        source 'server.properties.erb'
        owner '#######'
        group '#######'
        mode '0755'
        variables({
        	:server_cluster_name => server_cluster_name,
        	:server_name => server_name,
        	:server_host => host_cluster_member_name,
		    :server_port_prefix => server_port_prefix,
		    :ldap_bind_key => ldap_bind_key,
		    :ssl_cert_file => ssl_cert_file,
		    :ssl_cert_key_file => ssl_cert_key_file
  		})
      end

       template "#{server_dir}/conf/server.xml" do
        source 'server.xml.erb'
        owner '#######'
        group '#######'
        mode '0755'
        variables({
        	:remote_cluster_members => remote_cluster_members
  		})
      end

       template "#{tc_install_dir}/conf/httpd/#{server_name}.conf" do
        source 'balancer.conf.erb'
        owner '#######'
        group '#######'
        mode '0755'
        variables({
        	:server_cluster_name => server_cluster_name,
        	:server_port_prefix => server_port_prefix,
        	:remote_cluster_members => attrs['remote_cluster_members']

  		})
  		not_if{ !(attrs.has_key?('remote_cluster_members') && ! attrs['remote_cluster_members'].empty?) }
      end

    ruby_block 'Add server entries to servers.conf' do
		  block do
			   fe = Chef::Util::FileEdit.new("#{tc_install_dir}/conf/servers.conf")
			   fe.insert_line_if_no_match(/#{server_name}/,"#{server_name}=#{server_port_prefix}")
			   fe.write_file
			end
		action :run
	end

    if add_mq7==true
     	::Dir.glob("#{tc_install_dir}tomcat8/lib/ibm/mq7-*/.*").each do |jar|
     		base_name = ::File.basename(jar)
     		link "#{server_dir}/lib/#{base_name}" do
			  to "#{jar}"
			end
     	 end
     	 
     	link "#{server_dir}/lib/javax.jms-api-2.0.jar" do
			  to "#{tc_install_dir}tomcat8/lib/java/javax.jms-api-2.0.jar"
		end
    end
    
    link "#{server_dir}/libtomcat-security-2.0.0.jar" do
		 to "#{tc_install_dir}tomcat8/libtomcat-security-2.0.0.jar"
	end

	link "#{tc_install_dir}tomcat8/doc-root/logs/#{server_name}" do
		 to "#{server_dir}/logs"
	end

end
