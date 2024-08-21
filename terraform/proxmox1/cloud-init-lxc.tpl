datasource_list: [ NoCloud ]
datasource:
  NoCloud:
    meta-data:
      instance-id: literallyanything
      local-hostname: myhostname
    user-data: |
      #cloud-config
      user: ${lxc_user}
      password: ${lxc_pw}
      sudo: ALL=(ALL) NOPASSWD:ALL
      chpasswd:
        expire: False
      users:
      - default
      package_upgrade: true
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
      - apt install -y qemu-guest-agent && systemctl start qemu-guest-agent
