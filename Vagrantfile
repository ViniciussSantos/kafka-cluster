ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  config.vm.define "master01" do |node|
    node.vm.box               = "generic/ubuntu2004"
    node.vm.box_check_update  = false
    node.vm.hostname          = "master01.kubernetes.cluster"
    node.vm.network "private_network", ip: "192.168.60.11", name: "vboxnet0"
    node.vm.provider :virtualbox do |v|
      v.name    = "master01"
      v.memory  = 2048
      v.cpus    = 2
    end
    node.vm.provider :libvirt do |v|
      v.memory  = 2048
      v.nested  = true
      v.cpus    = 2
    end
    node.vm.provision "shell", path: "scripts/prepare.sh", args: "master"
  end
  (1..3).each do |i|
    config.vm.define "worker0#{i}" do |node|
      node.vm.box               = "generic/ubuntu2004"
      node.vm.box_check_update  = false
      node.vm.hostname          = "worker0#{i}.kubernetes.cluster"
      node.vm.network "private_network", ip: "192.168.60.2#{i}"
      node.vm.provider :virtualbox do |v|
        v.name    = "worker0#{i}"
        v.memory  = 2048
        v.cpus    = 2
      end
      node.vm.provider :libvirt do |v|
        v.memory  = 2048
        v.nested  = true
        v.cpus    = 2
      end
      node.vm.provision "shell", path: "scripts/prepare.sh", args: "worker"
    end
  end
end
