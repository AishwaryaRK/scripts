#!/usr/bin/env bash
POST_INSTALL_START="### MOTD Script Start ###"
POST_INSTALL_END="### MOTD Script End ###"

motd_uninstall()
{
  echo "uninstalling motd"
  if [ "$(uname)" == "Darwin" ]; then
    ## mac os x
    echo "detected mac os x"

    # remove from bashrc
    sed -i'.bak' "/$POST_INSTALL_START/,/$POST_INSTALL_END/d" ~/.bashrc

    # http://nathangrigg.net/2012/07/schedule-jobs-using-launchd/
    launchctl unload ~/Library/LaunchAgents/sh.motd.generator.plist
    rm ~/Library/LaunchAgents/sh.motd.generator.plist
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "detected linux"

    # remove cronjob
    CRONCMD="/home/$USER/.motd.sh"
    crontab -l | grep -v $CRONCMD | crontab -

    # remove from bashrc
    sed -i'.bak' "/$POST_INSTALL_START/,/$POST_INSTALL_END/d" ~/.bashrc

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
