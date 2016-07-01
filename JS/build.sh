#!/bin/bash

PUBLIC="../../sample-app/public"
SRC_PATH="../opentok.js-ss-annotation/src/"
IMAGES_PATH="../opentok.js-ss-annotation/images"
CSS_PATH="../opentok.js-ss-annotation/css"
ANNOTATIONS_PATH="../opentok.js-ss-annotation/annotations"

function fetchAnnotationsDep()
{
  
  echo "Fetching Annotations dependency"

  PREBUILT_URL="https://s3.amazonaws.com/artifact.tokbox.com/solution/rel/annotations/JS/opentok-js-annotations-1.0.0.zip"

  curl -s "$PREBUILT_URL" > annotations.zip 

  gulp unzip
  rm annotations.zip  
  
  copyAnnotationsDep

}

function copyAnnotationsDep()
{	
	cp -v $ANNOTATIONS_PATH/opentok-annotations.js $SRC_PATH/
	cp -v -r $ANNOTATIONS_PATH/images/* $IMAGES_PATH
	cp -v $ANNOTATIONS_PATH/annotation.css $CSS_PATH
}

if [[ -d opentok.js-ss-annotation ]]
then
	cd opentok.js-ss-annotation
	
	fetchAnnotationsDep
	
	gulp dist
        gulp zip
	cd dist 
    cp -v screenshare-annotation-acc-pack.js $PUBLIC/js/components/screenshare-annotation-acc-pack.js
    cp -v theme.css $PUBLIC/css/theme.css
    cp -r -v images/* $PUBLIC/images/
	
	if [[ -f "../screenshare.html" ]]
	then
		mkdir $PUBLIC/templates
		cp -v ../screenshare.html $PUBLIC/templates/screenshare.html
	fi
else 
	echo "Please run this script from 'js-screensharing-annotation'."
	exit 1
fi

