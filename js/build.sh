#!/bin/bash

PUBLIC="../../sample-app/public"
LOGGING="../../sample-app/node_modules/opentok-solutions-logging/opentok-solutions-logging.js"

if [[ -d opentok.js-text-chat ]]
then
	cd opentok.js-text-chat
	npm i
	npm update
  cp -v node_modules/opentok-one-to-one-communication/opentok-one-to-one-communication.js src/opentok-one-to-one-communication.js
	cp -v node_modules/opentok-solutions-logging/opentok-solutions-logging.js src/opentok-solutions-logging.js
	gulp dist
	cd dist
    cp -v text-chat-acc-pack.js $PUBLIC/js/components/text-chat-acc-pack.js
    cp -v theme.css $PUBLIC/css/theme.css
    	gulp zip
else
	echo "Please run this script from 'JS'."
	exit 1
fi

