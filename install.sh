#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root(!)" 
	exit 1
fi

MAIN_PATH="/opt/hacktivity-notify"
LOCAL_BIN="/usr/local/bin"

function _dlResources() {
	echo "Create main directory..."
	mkdir -p $MAIN_PATH
	echo "Downloading notify-send.sh..."
	wget -q "https://github.com/vlevit/notify-send.sh/raw/master/notify-send.sh" -O $LOCAL_BIN/notify-send
	wget -q "https://github.com/vlevit/notify-send.sh/raw/master/notify-action.sh" -O $LOCAL_BIN/notify-action.sh
	chmod 777 $LOCAL_BIN/notify-*
	cp -a assets/ $MAIN_PATH
	cp hacktivity-notify.sh $MAIN_PATH/hacktivity-notify
	chmod -R +x $MAIN_PATH/
}

function _dependencies() {
	if ! [ -x "$(which jq)" ]; then
		JQ_OUT="/usr/local/bin/jq"
		echo "Downloading jq..."
		wget -q "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux$(getconf LONG_BIT)" -O $JQ_OUT
		chmod 777 $JQ_OUT
	else
		echo "jq OK!"
	fi

	if ! [ -x "$(which curl)" ]; then
		echo "Downloading cURL..."
		wget -q "https://curl.haxx.se/download/curl-7.68.0.tar.gz" -O /tmp/
		tar -xf /tmp/curl-7* && cd /tmp/curl-7*
		echo "Installing cURL..."
		/./$PWD/configure && make && make install
	else
		echo "curl OK!"
	fi
}

function _setCrontab() {
	CRON_CURRENT="/tmp/cron.current"
	crontab -l > $CRON_CURRENT
	echo "0 */1 * * * $MAIN_PATH/hacktivity-notify" >> $CRON_CURRENT
	echo "Installing new crontab"
	crontab $CRON_CURRENT
}

echo "##### Installing resources #####"
_dlResources
echo "##### Installing dependencies #####"
_dependencies
# echo "##### Setting up crontab #####"
# #_setCrontab # run this as user