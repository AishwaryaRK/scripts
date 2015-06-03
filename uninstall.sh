#!/usr/bin/env bash

set -e

motd_uninstall()
{
  echo "uninstalling motd.sh"
  # http://nathangrigg.net/2012/07/schedule-jobs-using-launchd/
  launchctl unload ~/Library/LaunchAgents/sh.motd.generator.plist
  rm ~/Library/LaunchAgents/sh.motd.generator.plist
}

motd_uninstall
