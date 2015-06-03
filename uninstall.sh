#!/usr/bin/env bash

# http://nathangrigg.net/2012/07/schedule-jobs-using-launchd/
launchctl unload ~/Library/LaunchAgents/sh.motd.generator.plist

rm ~/Library/LaunchAgents/sh.motd.generator.plist
