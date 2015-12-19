#!/bin/sh

jazzy -m "StreamOneSDK" \
	-a "StreamOne" \
	-u https://streamone.nl \
	-g https://github.com/StreamOneNL/iOS-SDK \
	--github-file-prefix https://github.com/StreamOneNL/iOS-SDK/blob/master \
	--module-version 3.0 \
	-x '-project,StreamOneSDK.xcodeproj,-scheme,StreamOneSDK-iOS' \
	-c