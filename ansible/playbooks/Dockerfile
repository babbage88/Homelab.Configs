FROM amd64/debian:bookworm-slim AS builder

WORKDIR /development

RUN apt update && apt upgrade -y && \   
    apt install -y git wget ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen && \
    wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz && \
    echo 'export PATH=/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> .bashrc && \
    rm go1.23.4.linux-amd64.tar.gz && git clone https://github.com/neovim/neovim.git && cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install
    

FROM amd64/debian:bookworm-slim AS final
WORKDIR /development

COPY --from=builder --chown=1000:1000 /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=builder --chown=1000:1000 /usr/local/go /usr/local/go
COPY --from=builder --chown=1000:1000 /development/.bashrc .bashrc
COPY --from=builder --chown=1000:1000 /usr/local/share/nvim/ /usr/local/share/

RUN apt update && apt upgrade -y && \ 
    apt install -y python3 curl jq dnsutils nfs-common bash-completion git wget && git clone https://github.com/LazyVim/starter ~/.config/nvim && \
    rm -rf .config/nvim/.git && wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh  && chmod +x install.sh && apt purge wget

USER jtrahan

    
#ENTRYPOINT [ "/bin/bash" ]





