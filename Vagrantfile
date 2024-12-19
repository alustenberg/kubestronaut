# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# https://blog.scottlowe.org/2016/01/14/improved-way-yaml-vagrant/
boxes = YAML.load_file(File.join(File.dirname(__FILE__), 'boxes.yml'))
groups = {}

PREFIX = boxes['prefix']
BOXES = boxes['boxes']

Vagrant.configure("2") do |config|
  config.vm.box = boxes['box']
  config.vm.synced_folder '.', '/vagrant', disabled: true

  BOXES.each_with_index do |(k,v),idx1|
    groups[k] = []
    (1..v['count']).each do |i|
      hostname = "vagrant-#{ k }-#{'%02d' % (i)}"
      groups[k].append(hostname)
      config.vm.define "#{hostname}" do |node|
        node.vm.hostname = "#{hostname}"
        node.vm.network "private_network", ip: "#{PREFIX}.#{v['offset']+i}"
        node.vm.provider "libvirt" do |lv|
          lv.cpus = v['cpu']
          lv.memory=v['memory']
          lv.machine_virtual_size=v['disk']
        end

        # on last machine, run ansible global
        if idx1 == BOXES.size - 1 and i == v['count']
          node.vm.provision "ansible" do |ansible|
            ansible.playbook="playbook-site.yml"
            ansible.limit="all"
            ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
            ansible.groups = groups
            ansible.become = true
          end
        end
      end
    end
  end
end
