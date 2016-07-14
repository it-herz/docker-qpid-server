#!/bin/bash
cat /usr/etc/qpid/qpidd.conf.dist | sed "s/DOMAIN/$DOMAIN/g" | sed "s/REALM/$REALM/g" >/usr/etc/qpid/qpidd.conf
cat /usr/etc/qpid/qpidd.acl.dist | sed "s/REALM/$REALM/g" >/usr/etc/qpid/qpidd.acl
rm /var/lib/qpidd/qpidd.sasldb
echo admin | saslpasswd2 -c -p -f /var/lib/qpidd/qpidd.sasldb -u $REALM admin
cd /var/lib/qpidd
/usr/sbin/qpidd
