#!/bin/bash
cat /usr/etc/qpid/qpidd.conf.dist | sed "s/DOMAIN/$DOMAIN/g" | sed "s/REALM/$REALM/g" >/usr/etc/qpid/qpidd.conf
#cat /usr/etc/qpid/qpidd.acl.dist | sed "s/REALM/$REALM/g" >/usr/etc/qpid/qpidd.acl
rm /var/lib/qpidd/qpidd.sasldb

# env: AUTH=login:password;login:password;...

touch /usr/etc/qpid/qpidd.acl
IFS=';'
for ITEM in $AUTH
do
  login=`echo $ITEM | awk -F':' ' { print $1 } '`
  password=`echo $ITEM | awk -F':' ' { print $2 } '`
  echo $password | saslpasswd2 -c -p -f /var/lib/qpidd/qpidd.sasldb -u $REALM $login
  echo "acl allow $login@$REALM all all" >>/usr/etc/qpid/qpidd.acl
done
unset IFS

echo "acl deny-log all all" >>/usr/etc/qpid/qpidd.acl

cd /var/lib/qpidd
/usr/sbin/qpidd
