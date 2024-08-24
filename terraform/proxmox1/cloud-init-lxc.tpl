datasource_list: [ NoCloud ]
datasource:
  NoCloud:
    meta-data:
      instance-id: cloudiniid123
    user-data: |
      #cloud-config
      users:
      - name: ${lxc_user}
        gecos: Justin Trahan
        primary_group: ${lxc_user}
        groups: sudo
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
         - ${lxc_ssh_key}
        passwd: ${lxc_pw}
      package_upgrade: true
      shell: /bin/bash
      packages:
      - curl
      - wget
      - jq
      - git
      - vim
      - net-tools
      - python-is-python3
      - dotnet-sdk-8.0
      - apt-cacher-ng
      runcmd:
      - mkdir /gotmp
      - [wget, "https://go.dev/dl/go1.23.0.linux-amd64.tar.gz", -O, /gotmp/go.tar.gz]
      - [tar, -xzvf, /gotmp/go.tar.gz, -C, /usr/local]
      - [bash, -c, "echo 'export PATH=/usr/local/go/bin:$PATH' >> /home/${lxc_user}/.bashrc"]
