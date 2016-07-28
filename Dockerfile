FROM debian:latest

MAINTAINER Dmitrii Zolotov <dzolotov@herzen.spb.ru>

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's~http://httpredir.debian.org~http://mirror.yandex.ru~ig' /etc/apt/sources.list && \
    apt-get update && apt-get dist-upgrade -y && apt-get install -y uuid-dev clang libssl-dev libsasl2-dev wget cmake make ruby-dev doxygen ruby valgrind pkg-config libboost-all-dev libdb5.3++-dev libdb-dev libaio-dev swig libxqilla-dev libxerces-c-dev libpthread-stubs0-dev libnss3-dev libnspr4-dev python-dev graphviz help2man krb5-user libgssapi-krb5-2 subversion maven openjdk-7-jdk python-setuptools sasl2-bin && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

RUN cd /root && mkdir proton && cd proton && wget https://dist.apache.org/repos/dist/release/qpid/proton/0.13.1/qpid-proton-0.13.1.tar.gz && tar xzvpf qpid-proton* && \
    cd qpid-proton* && mkdir build && cd build && CXX=clang++ CC=clang cmake -DCMAKE_CXX_FLAGS=-std=c++11 -DSYSINSTALL_BINDINGS=ON -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make && make install

RUN cd /root && mkdir qpid && cd qpid && svn co https://svn.apache.org/repos/asf/qpid/tags/qpid-cpp-0.34/qpid/ . && \
    cd cpp && mkdir build && cd build && CXX=clang++ CC=clang cmake -DBUILD_TESTING=no -DBUILD_PROBES=no -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make all && make install && cd /root/qpid && \
    cd extras/qmf && ./setup.py build install && \
    cd ../../python && ./setup.py build install && \
    cd ../tools && ./setup.py build install

RUN cd /root && mkdir qpid-web && cd qpid-web && svn co https://svn.apache.org/repos/asf/qpid/trunk/qpid/tools/src/java/ . && \
    cd /root/qpid-web && find . -name pom.xml -exec sed -i "s/0.32-SNAPSHOT/0.32/g" {} \; && mvn clean package && \
    cd qpid-qmf2-tools/target && mkdir /qmfweb && mv qpid-qmf2-tools-0.32-bin.tar.gz /qmfweb && cd /qmfweb && \
    tar xzvpf qpid-qmf2-tools-0.32-bin.tar.gz && mv qpid-qmf2-tools/0.32/* . && rm -f qpid-qmf2-tools-0.32-bin.tar.gz
# && \
#    cd /root && wget http://apache-mirror.rbc.ru/pub/apache/qpid/0.32/qpid-tools-0.32.tar.gz && \
#    tar xzvpf qpid-tools* && cd qpid-tools* && ./setup.py build install && rm -rf /root && mkdir /root

RUN mkdir /var/log/supervisor/ && mkdir /var/lib/qpidd
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
RUN /usr/bin/easy_install supervisor-logging
ADD supervisord.conf /etc/supervisord.conf

VOLUME ["/var/db/qpidd"]

ADD qpidd.acl /usr/etc/qpid/qpidd.acl.dist
ADD qpidd.conf /usr/etc/qpid/qpidd.conf.dist
ADD sasl.conf /usr/etc/sasl2/qpidd.conf
ADD config.js /qmfweb/bin/qpid-web/web/ui/config.js.dist

ADD runQPID.sh /
ADD runREST.sh /qmfweb/bin

ENV DOMAIN domain.com
ENV REALM DOMAIN
ENV EXTIP 127.0.0.1

EXPOSE 5672 8080

CMD ["supervisord","-n","-c","/etc/supervisord.conf"]
