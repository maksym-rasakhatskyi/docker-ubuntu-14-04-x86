# This docker file contains build environment
FROM savoirfairelinux/ring-ubuntu32:14.04
MAINTAINER maliy.sergey <maliy.sergey@apriorit.com>
RUN apt-get update && apt-get install -y bison++ tcl libxalan-c-dev libxerces-c-dev libprocps3-dev \
libnl-3-dev libcrypto++-dev libpcre++-dev uuid-dev libsnappy-dev build-essential libboost-all-dev cmake maven \
libicu-dev zlib1g-dev liblog4cpp5-dev libncurses5-dev libselinux1-dev wget libsqlite3-dev \
google-mock libvirt-dev libmysqlclient-dev qtbase5-dev qtdeclarative5-dev \
libjpeg-turbo8-dev libnuma-dev automake autoconf autotools-dev libevent-dev thrift-compiler \
libboost-dev libboost-test-dev libboost-program-options-dev libboost-filesystem-dev libboost-thread-dev libevent-dev \
libtool flex pkg-config libssl-dev libblkid-dev \
libc6 libc6-dev g++-multilib \
giblib-dev libimlib2-dev libglib2.0-dev libgtk-3-dev libcanberra-gtk3-dev libpam0g-dev

RUN cd /tmp && wget https://github.com/emcrisostomo/fswatch/releases/download/1.9.3/fswatch-1.9.3.tar.gz && tar xf fswatch-1.9.3.tar.gz && \
cd fswatch-1.9.3 && ./configure && make install && cd ../ && rm -rf fswatch-1.9.3.tar.gz && rm -rf fswatch-1.9.3

RUN cd /tmp && wget https://archive.apache.org/dist/thrift/0.9.3/thrift-0.9.3.tar.gz && tar xf thrift-0.9.3.tar.gz && cd thrift-0.9.3 && ./configure --without-qt4 --without-qt5 --without-java --without-ruby --disable-tests && make install && cd .. && rm -rf thrift-0.9.3 thrift-0.9.3.tar.gz

RUN  cd /tmp && wget http://nixos.org/releases/patchelf/patchelf-0.8/patchelf-0.8.tar.gz && tar xf patchelf-0.8.tar.gz && patchelf-0.8/configure && make install && rm -rf patchelf-0.8 && rm -f patchelf-0.8.tar.gz
# Custom build of xalan-c lib
RUN cd /tmp && apt-get source libxalan-c111 && cd ./xalan-1.11/c/ && export XALANCROOT=/tmp/xalan-1.11/c && ./runConfigure -p linux -c gcc -x g++ -d && make && cp -pr ./lib/lib* /usr/lib/i386-linux-gnu/

RUN cd /usr/src/gmock/gtest/ && cmake . && make && cp -r include/gtest /usr/include && cp *.a /usr/lib
RUN cd /usr/src/gmock/ && cmake . && make && cp *.a /usr/lib

RUN apt-get install -y git bison

# install cmake 3.14
RUN apt remove cmake -y
RUN cd /tmp && wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz && tar xf cmake-3.14.5.tar.gz && cd /tmp/cmake-3.14.5 && ./bootstrap --prefix=/usr -- -DCMAKE_BUILD_TYPE:STRING=Release && make -j2 && make install && cd ../ && rm -rf cmake-3.14.5 && rm -rf cmake-3.14.5.tar.gz

# boost 1.66.0
RUN cd /tmp && wget --no-check-certificate http://sourceforge.net/projects/boost/files/boost/1.66.0/boost_1_66_0.tar.gz && tar zxvf boost_1_66_0.tar.gz && cd boost_1_66_0 && ./bootstrap.sh --with-icu --with-libraries=system,filesystem,thread,regex,locale,chrono,program_options,date_time,serialization,test --libdir=/usr/lib/x86_64-linux-gnu --includedir=/usr/include && ./b2 && ./b2 install && cd - && ldconfig

# liblightgrep
RUN cd /tmp && git clone --recursive https://github.com/ligen-ua/liblightgrep.git && cd liblightgrep && autoreconf -fi && ./configure --with-boost-libdir=/usr/lib/i386-linux-gnu/ && make && make install

# sqlite3
RUN  cd /tmp && wget --no-check-certificate https://sqlite.org/src/tarball/version-3.31.1/sqlite.tar.gz && tar xf sqlite.tar.gz && cd sqlite && autoconf && ./configure && make && make install && cd .. && rm -rf sqlite sqlite.tar.gz

# ext2fs
RUN apt-get install -y e2fslibs-dev

# openssl 1.1.1
RUN cd /tmp && wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1n.tar.gz && tar xf openssl-1.1.1n.tar.gz && cd openssl-1.1.1n && ./config && make && make install && cd .. && rm -rf openssl-1.1.1n && rm -f openssl-1.1.1n.tar.gz && ldconfig