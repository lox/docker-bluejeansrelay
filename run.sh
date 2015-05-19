#!/bin/bash -e

encrypt_password() {
	cd /opt/listenerservice
	sudo -u listenerservice java -jar /opt/listenerservice/listenerservice*.jar \
	  --encrypt-password "$1" "$2"
}

if [[ -z $AMQP_USERNAME ]] ; then
	echo "Must set $AMQP_USERNAME"
	exit 1
fi

if [[ -n $AMQP_PLAINTEXT_PASSWORD && -z $AMQP_PASSWORD ]] ; then
	echo "encrypting password"
	export AMQP_PASSWORD=$(encrypt_password $AMQP_USERNAME $AMQP_PLAINTEXT_PASSWORD)
fi

cat << EOF > /opt/listenerservice/config.properties
amqp.host=relay.bluejeans.com
amqp.username=$AMQP_USERNAME
amqp.password=$AMQP_PASSWORD
listenerServiceId=$LISTENER_SERVICE
EOF

/opt/listenerservice/bin/startDaemonNoPriv.sh
tail -f /opt/listenerservice/log/wrapper.log

# If you're setting up MS Exchange polling, uncomment the next four lines
# and configure accordingly.  Note that the password is encrypted; see the
# password encryption instructions above.

#calendar.exchange.soapUri=https://ews.localdomain/EWS/Exchange.asmx
#calendar.exchange.username=catalyst
#calendar.exchange.password=
#calendar.exchange.domain=

# If you're using public key encryption for your endpoint passwords,
# uncomment the next line and point it to your private key. (Your public
# key will be provisioned on our cloud service.)
#
# Be sure your private key is protected and readable only by the user
# running the Listener Service!

#encryption.private_key_file=private.der

# The next two parameters are optional/experimental and used if you wish to
# use multicast configuration discovery of alternate API servers (uncommon).

#api.uri=https://relay.bluejeans.com/api
#api.name=Production