#!/bin/bash

if [[ -d opentok.js-annotations ]]
then
	cd opentok.js-annotations
	gulp dist
	cd dist

else
	echo "Please run this script from 'JS'."
	exit 1
fi
