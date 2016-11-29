#!/bin/bash

INIT_AVG=1000

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

avg=$INIT_AVG

while true; do
	output=$(ping -c 1 -t 1 8.8.8.8)

	if [[ $! -ne 0 ]]; then
		count=0
		avg=$INIT_AVG
		continue
	fi

	count=$((count + 1))

	if [[ $count -lt 5 ]]; then
		continue
	fi

	time=$(echo $output | cut -d' ' -f 7 | cut -d= -f2)

	avg=$(echo "$avg * 0.8 + $time * 0.2" | bc | cut -d. -f1)

	if [[ $avg -lt 200 ]]; then
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
