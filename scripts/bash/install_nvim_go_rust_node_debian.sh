#!/bin/bash

install_updates() {
	sudo apt-get update -y
	sudo apt-get upgrade -y
}

# Install pre-reqs
install_apt_reqs() {
	sudo apt-get install -y wget tar curl python3-venv git ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
}

# install cargo
install_rust_cargo() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

#install uv for python
install_uv() {
	curl -LsSf https://astral.sh/uv/install.sh | sh
}

# install nvm
install_nvm_node() {
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

	# add nvm to PATH
	export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

	nvm install --lts
}

install_dotnet_sdk() {
	# install dotnet 9.0 sdk
	sudo add-apt-repository ppa:dotnet/backports
	sudo apt-get update &&
		sudo apt-get install -y dotnet-sdk-9.0
}

install_golang() {
	#install golang
	wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
	sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz
	echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.bashrc
	echo 'export GOPATH=$HOME/go' >>~/.bashrc
	echo 'export GOBIN=$GOPATH/bin' >>~/.bashrc
}

install_nvim_from_source() {
	#install neovim from source
	git clone --depth 1 https://github.com/neovim/neovim.git
	cd neovim
	make CMAKE_BUILD_TYPE=RelWithDebInfo
	sudo make install
}

install_lazyvim() {
	# isntall lazyvim
	git clone https://github.com/LazyVim/starter ~/.config/nvim
	rm -rf ~/.config/nvim/.git
}

install_updates
install_apt_reqs
install_rust_cargo
install_uv
install_nvm_node
install_golang
install_dotnet_sdk
install_nvim_from_source
install_lazyvim
