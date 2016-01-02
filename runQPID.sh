#!/bin/bash
cat /usr/etc/qpid/qpidd.conf.dist | sed "s/DOMAIN/$DOMAIN/g" | sed "s/REALM/$REALM/g" >/usr/etc/qpid/qpidd.conf
cat /usr/etc/qpid/qpidd.acl.dist | sed "s/REALM/$REALM/g" >/usr/etc/qpid/qpidd.acl
cd /var/lib/qpidd
/usr/sbin/qpidd
