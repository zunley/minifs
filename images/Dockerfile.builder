FROM debian:stable

LABEL maintainer "merore <merore256@outlook.com>"

RUN apt update -y && \
  apt install build-essential bc texinfo gawk bison python3 ninja-build pkg-config libglib2.0-dev -y

CMD ["/bin/bash"]
