#!/bin/bash

PUBLIC="../../sample-app/public"

if [[ -d opentok.js-text-chat ]]
then
	cd opentok.js-text-chat
	gulp dist
	cd dist 
    cp -v text-chat-acc-pack.js $PUBLIC/js/components/text-chat-acc-pack.js
    cp -v theme.css $PUBLIC/css/theme.css
else 
	echo "Please run this script from 'JS'."
	exit 1
fi

