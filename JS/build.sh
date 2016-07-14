#!/bin/bash

PUBLIC="../../sample-app/public"
SRC_PATH="../opentok.js-ss-annotation/src/"
IMAGES_PATH="../opentok.js-ss-annotation/dist/images"
TEMPLATES_PATH="../opentok.js-ss-annotation/dist/templates"
CSS_PATH="../opentok.js-ss-annotation/css"
ANNOTATIONS_PATH="../opentok.js-ss-annotation/annotations"
NPM_MODULES="../opentok.js-ss-annotation/node_modules"

function fetchNpmPackages()
{
  echo "Fetching NPM Packages"
	npm i
	echo "Checking for NPM Updates"
	npm update

  copyDependencies
}

function copyDependencies()
{
	echo "Copying NPM Packages"
	cp -v $NPM_MODULES/opentok-one-to-one-communication/opentok-one-to-one-communication.js $SRC_PATH
	cp -v $NPM_MODULES/opentok-annotation/dist/opentok-annotation.js $SRC_PATH
	cp -v $NPM_MODULES/opentok-annotation/css/annotation.css $CSS_PATH
	cp -v $NPM_MODULES/opentok-annotation/templates/screenshare.html $TEMPLATES_PATH
	cp -v $NPM_MODULES/opentok-annotation/images/* $IMAGES_PATH/annotation
	cp -v $NPM_MODULES/opentok-screen-sharing/dist/opentok-screen-sharing.js $SRC_PATH
	cp -v $NPM_MODULES/opentok-screen-sharing/css/screen-share.css $CSS_PATH
	cp -v $NPM_MODULES/opentok-text-chat/dist/opentok-text-chat.js $SRC_PATH
	cp -v $NPM_MODULES/opentok-solutions-logging/opentok-solutions-logging.js $SRC_PATH
}

if [[ -d opentok.js-ss-annotation ]]
then
	cd opentok.js-ss-annotation

	fetchNpmPackages

	gulp dist
        gulp zip
	cd dist
    cp -v screenshare-annotation-acc-pack.js $PUBLIC/js/components/screenshare-annotation-acc-pack.js
    cp -v theme.css $PUBLIC/css/theme.css
    cp -r -v images/* $PUBLIC/images/
		cp -r -v templates/* $PUBLIC/templates/

	if [[ -f "../screenshare.html" ]]
	then
		mkdir $PUBLIC/templates
		cp -v $TEMPLATES_PATH/screenshare.html $PUBLIC/templates
	fi
else
	echo "Please run this script from 'js-screensharing-annotation'."
	exit 1
fi

