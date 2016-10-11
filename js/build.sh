#!/bin/bash
set -e

if [[ -d opentok.js-screen-sharing ]]
then
	cd opentok.js-screen-sharing
	gulp dist
	gulp zip
  cd dist

else
	echo "Please run this script from 'JS'."
	exit 1
fi
