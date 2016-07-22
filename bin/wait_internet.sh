#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "You must supply exactly one file name" >&2
	exit 1
fi

if [[ ! -r "$1" || ! -f "$1" ]]; then
	echo "File $1 does not exist, is not readable, or is not a file" >&2
	exit 1
fi

stop_loop=false

function stop() {
	stop_loop=true
}

trap stop INT

while true; do
	if ping -c 1 -t 1 8.8.8.8; then
		echo "HOORAY! The internet is back"
		break
	fi
	if $stop_loop; then
		echo "Interrupted"
		break
	fi
done

if ! $stop_loop; then
	open "$1"
fi
