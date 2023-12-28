#!/bin/sh

PATH=$PATH:/opt/homebrew/bin:/usr/local/bin
if command -v swiftformat >/dev/null 2>&1; then
	swiftformat "$@"
else
	echo "Please install swiftformat with 'brew install swiftformat'."
fi

