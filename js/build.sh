#!/bin/bash
set -e

task="$1"

#Run unit tests
if [ "$task" == "-t" ]; then
	npm install -g jasmine
	jasmine
	exit 0
fi

#Create zip file with JS and doc
if [ "$task" == "-d" ]; then

	# npm install gulp
	# npm install gulp-concat gulp-import-css gulp-uglify gulp-zip gulp-unzip gulp-concat-css

if [[ -d opentok.js-annotations ]]
then
	cd opentok.js-annotations
	npm i
	npm update
	gulp dist
	cd dist
	gulp zip
	exit 0
else
	echo "Please run this script from 'JS'."
	exit 1
fi
fi

echo Invalid parameters, please use ‘-t’ to run tests or ‘-d’ to create zip file with JS and doc.
exit 1
