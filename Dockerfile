FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y uuid-dev clang libssl-dev libsasl2-dev wget cmake make ruby-dev doxygen ruby valgrind pkg-config libboost-all-dev libdb5.3++-dev libdb-dev libaio-dev swig libxqilla-dev libxerces-c-dev libpthread-stubs0-dev libnss3-dev libnspr4-dev python-dev graphviz help2man

RUN cd /root && mkdir proton && cd proton && wget https://dist.apache.org/repos/dist/release/qpid/proton/0.11.1/qpid-proton-0.11.1.tar.gz && tar xzvpf qpid-proton* && \
    cd qpid-proton* && mkdir build && cd build && CXX=clang++ CC=clang cmake -DCMAKE_CXX_FLAGS=-std=c++11 -DSYSINSTALL_BINDINGS=ON -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make && make install

RUN cd /root/proton && wget https://dist.apache.org/repos/dist/release/qpid/cpp/0.34/qpid-cpp-0.34.tar.gz && tar xzvpf qpid-cpp* && \
    cd qpid-cpp* && mkdir build && cd build && CXX=clang++ CC=clang cmake -DBUILD_TESTING=no -DBUILD_PROBES=no -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make qpidbroker qpidclient && make install

VOLUME ["/var/db/qpidd","/var/lib/qpidd/qpidd.sasldb"]

ADD qpidd.acl /usr/etc/qpid/qpidd.acl
ADD qpidd.conf /usr/etc/qpid/qpidd.conf	
ADD sasl.conf /usr/etc/sasl2/qpidd.conf

EXPOSE 5672

ENTRYPOINT /usr/sbin/qpidd
