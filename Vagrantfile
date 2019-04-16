# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = 'ubuntu/bionic64'
  config.vm.define "atlas-dev-env"


  # Forward ports
  [
    { guest: 80, host: 8000 } # NginX
  ].each do |p|
    config.vm.network :forwarded_port, guest: p[:guest], host: p[:host]
  end

  # Provider configuration
  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--memory', '1024']
  end

  # Sync folders
  config.vm.synced_folder '.', '/vagrant', type: 'virtualbox'

  # Copy required sample configuration files
  config.vm.provision "file", source: "./provision/sample/values.env", destination: "values.env"
  config.vm.provision "file", source: "./provision/sample/nginx.conf", destination: "nginx.conf"

  # Machine initial provision
  config.vm.provision "shell", privileged: false, run: "once",
  path: "provision/virtual_dev_env.sh",
  env: {
    "LC_ALL"   => "en_US.UTF-8",
    "LANG"     => "en_US.UTF-8",
    "LANGUAGE" => "en_US.UTF-8",
  }
end
