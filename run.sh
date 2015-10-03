#!/bin/bash

die () {
    msg=$1
    echo "FATAL ERROR: " msg > 2
    exit
}

_startservice () {
    sv start $1 || die "Could not start $1"
}

startserver () {
    _startservice openvpn
}

addclient () {
    cd /etc/openvpn/easy-rsa
    . ./vars
    ./build-key --batch client1
    cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/easy-rsa/keys/client.ovpn

    # Creating solo-file-client-config
    cd /etc/openvpn/easy-rsa/keys

    FILE_CA=$(<ca.crt)
    FILE_CERT=$(<client1.crt)
    FILE_KEY=$(<client1.key)

    NL=$'\n'
    RES=$(<client.ovpn)
    RES=${RES/ca ca.crt/<ca>${NL}${FILE_CA}${NL}<\/ca>}
    RES=${RES/cert client.crt/<cert>${NL}${FILE_CERT}${NL}<\/cert>}
    RES=${RES/key client.key/<key>${NL}${FILE_KEY}${NL}<\/key>}
    echo ${RES} > ./client.ovpn
    
    cp ./client.ovpn /data/client.ovpn
    rm ./client*.*

    exit
}

cli () {
    echo "Running bash"
    cd /etc/openvpn/easy-rsa/keys
    exec bash
}

help () {
    cat /usr/local/share/doc/run/help.txt
    exit
}

_wait () {
    WAIT=$1
    NOW=`date +%s`
    BOOT_TIME=`stat -c %X /etc/container_environment.sh`
    UPTIME=`expr $NOW - $BOOT_TIME`
    DELTA=`expr 5 - $UPTIME`
    if [ $DELTA -gt 0 ]
    then
        sleep $DELTA
    fi
}

# Unless there is a terminal attached wait until 5 seconds after boot
# when runit will have started supervising the services.
if ! tty --silent
then
    _wait 5
fi

# Execute the specified command sequence
for arg 
do
    $arg;
done

# Unless there is a terminal attached don't exit, otherwise docker
# will also exit
if ! tty --silent
then
    # Wait forever (see
    # http://unix.stackexchange.com/questions/42901/how-to-do-nothing-forever-in-an-elegant-way).
    tail -f /dev/null
fi
