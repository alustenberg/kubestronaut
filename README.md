# kubestronaut

This is my working directory for completing the [CNCF Kubestronaut](https://www.cncf.io/training/kubestronaut/) certification package.

## Sources and Commit History

This is not a pretty portfolio, it's getting things done dirty.

sources and inspirations include, but are not limited to:

* https://github.com/talbotfoundry/k8s-kvm
* https://github.com/boxcutter/kvm/
* https://github.com/chef/bento

When snippets are pulled from repo issues, they are commented inline with references.

Branches are squashed, because save scumming is not a sin.

## Environment

created and ran on x86_64 Debian Linux.

virtual machines are x86_64 Ubuntu 24.04.1 Linux.

### SSH

Vagrant is configured to copy ~/.ssh/id_rsa.pub to the virtual machine's root user's authorized keys.  The vagrant makefile target will drop ssh configuration snippets into ~/.ssh/vagrant.d/.

```
Host vagrant-*
    User root
    RequestTTY yes
    IdentityFile ~/.ssh/id_rsa.pub

Include vagrant.d/*
```

```
$ ssh vagrant-control-01 -- kubectl apply -f - < manifests/pod.yaml
pod/box created
```

## Building

### `make python`

installs local python / pyenv runtime.  ansible, etc.

### `make packer`

builds base images and imports to vagrant.

must be explicitly ran first. not included in default build targets / dependencies, as it is quite a heavy operation.

`ubuntu24.pkr.hcl`: packer configuration file
`scripts/packer.sh`: base box provision script

### `make vagrant`

creates a 1 control node, 3 worker node k8s cluster by default.

`export VAGRANT_K8S_PROFILE='full'` will create a 3 control node, 5 worker node cluster.

`playbook-k8s.yml`: ansible playbook for provisioning basic cluster

# Certification Notes

## Blanket bullet points

* killer.sh exam simulators included are invaluable for finding weak spots
* Time and resource management.
  * Know key search terms for boilerplate in k8s official docs.
  * vimrc
    * add `set si` for smartindent
  * env
    * `export d="--dry-run=client -o yaml"`

## [K8s and Cloud Native Associate - KCNA](https://www.cncf.io/training/certification/kcna/)

* The CNCF Landscape is very intimidating.
  * take time to become familiar with graduated projects.

## [k8s Administrator - CKA](https://www.cncf.io/training/certification/cka/)

* cluster upgrade apply takes a very long time.
  * tmux and detach. flag the task, and come back after a few minutes.
* spend time wisely.  if a question is taking a lot of digging through docs, flag and come back to it.
  * 30% troubleshooting - quick work if you know where to look.
  * 25% arch, install, configuration
  * 20% services and networking
  * 15% workloads and scheduling - the deep magic.
  * 10% storage

## [k8s Application Developer - CKAD]()

* quite a bit of overlap from CKA.
* time management - topics are more even in weighting.
  * skip and flag time sinks

## [Security Associate - KCSA]()

* another large subject overlap with CKA, but multiple choice!

## [Security Specialist - CKS]()

* Required a pretty massive shift in local vagrant configuration.
  * Stuff that realistically should have been done for CKA.
  * Admin users and etcd encryption forced it.
