#!/bin/bash

PUBLIC="../../sample-app/public"

if [[ -d opentok.js-ss-annotation ]]
then
	cd opentok.js-ss-annotation
	gulp dev
	cd dist 
    cp -v screenshare-annotation-acc-pack.js $PUBLIC/js/components/screenshare-annotation-acc-pack.js
    cp -v theme.css $PUBLIC/css/theme.css
	cp -v ../screenshare.html $PUBLIC/templates/screenshare.html
else 
	echo "Please run this script from 'js-screensharing-annotation'."
	exit 1
fi

