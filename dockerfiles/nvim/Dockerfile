FROM amd64/debian:bookworm-slim as builder
WORKDIR /build
RUN apt update && apt upgrade -y && \
  apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen && \
  apt install -y git && \
  git clone https://github.com/neovim/neovim.git && cd neovim && \
  make CMAKE_BUILD_TYPE=RelWithDebInfo

FROM amd64/debian:bookworm-slim AS final
COPY --from=builder /build/neovim /root
