FROM amd64/debian:bookworm-slim

RUN apt update && apt upgrade -y && \ 
    apt install -y python3 wget curl jq dnsutils nfs-common bash-completion && \
    apt install -y git ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen && \
    wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz && \
    echo 'export PATH=/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> .bashrc && \ 
    git clone https://github.com/neovim/neovim.git && cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install && \
    git clone https://github.com/LazyVim/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git

ENTRYPOINT [ "/bin/bash" ]





