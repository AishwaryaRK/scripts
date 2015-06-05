#!/usr/bin/env bash

motd_uninstall()
{
  echo "uninstalling motd"
  if [ "$(uname)" == "Darwin" ]; then
    ## mac os x
    echo "detected mac os x"
    # http://nathangrigg.net/2012/07/schedule-jobs-using-launchd/
    launchctl unload ~/Library/LaunchAgents/sh.motd.generator.plist
    rm ~/Library/LaunchAgents/sh.motd.generator.plist
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "detected linux"
    CRONJOB="0 * * * * /home/$USER/.motd.sh"
    (crontab -l | grep -v "$CRONJOB") | crontab -
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    ## windows
    ## TODO: add support
    echo "detected windows"
    echo "windows is not currently supported"
    ## TODO: add github issue for this
    echo ""
    exit 1
  else
    echo "unknown operating system detected"
    exit 1
  fi
  echo "finished successfully."
}

motd_uninstall
