all: python

python:
	pyenv install 3.12.7 -s
	pip install --upgrade pip
	pip install -r requirements.txt

vagrant:
	vagrant destroy -f || true
	vagrant up
	vagrant ssh-config > ~/.ssh/vagrant.d/kubestronaut

packer: output/ubuntu24.box

output/ubuntu24.box:
	packer build -force ubuntu24.pkr.hcl
	vagrant box add --name packer/ubuntu-24 output/packer/ubuntu24.box --force

clean:
	rm -rfv output/packer
