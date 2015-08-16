FROM plumlife/crosstool-ng:gcc-4.9_eglibc-2.20
MAINTAINER parnell@plumlife.com

# Upgrade squeeze to wheezy
#
# This is being done here, rather than deriving from a base image
# because we already use the existing base image for another project
# and I don't feel like re-building the same cross-compiler toolchain
# on-top of wheezy at the moment and porting all other downstream
# containers.

RUN rm -f /etc/apt/sources.list
RUN echo "deb http://ftp.debian.org/debian/ wheezy main contrib non-free"             > /etc/apt/sources.list
RUN echo "deb-src http://ftp.debian.org/debian/ wheezy main contrib non-free"         >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ wheezy/updates main contrib non-free"       >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org/ wheezy/updates main contrib non-free"   >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y dist-upgrade

RUN apt-get -y install build-essential curl ghc git libncurses5-dev cabal-install \
  ca-certificates curl file m4 autoconf zlib1g-dev \
  llvm-3.0 \
  libgnutls-dev libxml2-dev libgsasl7-dev pkg-config python c2hs
WORKDIR /root
ENV TERM xterm

# Install automake-1.14
ADD root-scripts/install-automake.sh /root/
RUN bash -c ./install-automake.sh

# Set the working directory
ENV BASE /opt/arm

# FIXME: Move the adding of the patches until later in the Docker build,
# just before GHC is built
RUN mkdir -p $BASE/patches
ADD patches/* $BASE/patches/

ADD user-scripts/set-env.sh $BASE/
WORKDIR $BASE

#
# Update cabal
#
ADD user-scripts/update-host-cabal.sh $BASE/
RUN ./update-host-cabal.sh

#
# These downloads take quite a while and are annoying. I put them here
# at the beginning to get them out of the way. If something breaks in the
# build it would suck if you had to rewind to a Docker image BEFORE
# the downloads had occurred.
#
ADD user-scripts/download-iconv.sh $BASE/
RUN ./download-iconv.sh
ADD user-scripts/download-ncurses.sh $BASE/
RUN ./download-ncurses.sh
ADD user-scripts/download-gmp.sh $BASE/
RUN ./download-gmp.sh
ADD user-scripts/download-ghc.sh $BASE/
RUN ./download-ghc.sh

#
# Start preparing the environment.
#

ADD user-scripts/unpack-ncurses.sh $BASE/
RUN ./unpack-ncurses.sh

ADD user-scripts/set-env-1.sh $BASE/

#
# From this point on all scripts should include set-env-1.sh which
# itself builds upon set-env.sh
#

ADD user-scripts/build-iconv.sh $BASE/
RUN ./build-iconv.sh

ADD user-scripts/build-ncurses.sh $BASE/
RUN ./build-ncurses.sh

ADD user-scripts/build-gmp.sh $BASE/
RUN ./build-gmp.sh

ADD user-scripts/build-gsasl.sh $BASE/
RUN ./build-gsasl.sh

ADD user-scripts/build-libidn.sh $BASE/
RUN ./build-libidn.sh

ADD user-scripts/build-libxml2.sh $BASE/
RUN ./build-libxml2.sh

ADD user-scripts/build-nettle.sh $BASE/
RUN ./build-nettle.sh

ADD user-scripts/build-gnutls26.sh $BASE/
RUN ./build-gnutls26.sh

#
# At last we are ready to build GHC. First we build it for the host
# architecture and then we build the cross-compiler.
#

# This will take a while
ADD user-scripts/build-ghc-host.sh $BASE/
RUN ./build-ghc-host.sh

# This takes a while too
ADD user-scripts/build-ghc-cross-compiler.sh $BASE/
RUN ./build-ghc-cross-compiler.sh

ADD user-scripts/build-hsc2hs-wrapper.sh $BASE/
RUN ./build-hsc2hs-wrapper.sh

ADD user-scripts/build-cross-compile-cabal.sh $BASE/
RUN ./build-cross-compile-cabal.sh

ADD user-scripts/add-bindir-links.sh $BASE/
RUN ./add-bindir-links.sh

ADD user-scripts/update-cabal-install.sh $BASE/
RUN ./update-cabal-install.sh

#
# Now to add add some PATHs to the .bashrc
#
ADD user-scripts/add-paths-to-bashrc.sh $BASE/
RUN ./add-paths-to-bashrc.sh

#
# Now to clean up the build directory. It takes up a lot of space (3.6G).
#

WORKDIR /root
RUN rm -rf $BASE

ADD user-scripts/README /root/README
RUN cat README

