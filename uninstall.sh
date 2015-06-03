#!/usr/bin/env bash

motd_uninstall()
{
  # http://nathangrigg.net/2012/07/schedule-jobs-using-launchd/
  launchctl unload ~/Library/LaunchAgents/sh.motd.generator.plist
  rm ~/Library/LaunchAgents/sh.motd.generator.plist
}

motd_uninstall "$@"
