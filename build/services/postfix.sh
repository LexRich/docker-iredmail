#!/bin/sh

FILES="localtime services resolv.conf hosts"
for file in $FILES; do
    cp /etc/${file} /var/spool/postfix/etc/${file}
    chmod a+rX /var/spool/postfix/etc/${file}
done

trap_hup_signal() {
    echo "Reloading (from SIGHUP)"
    postfix reload
}

trap_term_signal() {
    echo "Stopping (from SIGTERM)"
    postfix stop
    exit 0
}

trap "trap_hup_signal" HUP
trap "trap_term_signal" TERM

/usr/lib/postfix/master -c /etc/postfix -d &
pid=$!

# Loop "wait" until the postfix master exits
while wait $pid; test $? -gt 128
do
    kill -0 $pid 2> /dev/null || break;
done
