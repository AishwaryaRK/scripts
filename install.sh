#!/usr/bin/env bash

MOTD_URL="https://raw.githubusercontent.com/messageoftheday/scripts/master/.motd.sh"
PLIST_URL="https://raw.githubusercontent.com/messageoftheday/scripts/master/sh.motd.generator.plist"
TERMINAL="please open a new terminal window to view the motd"

motd_install()
{
  echo "installing motd.sh"
  # detect environment
  # http://stackoverflow.com/a/3826462
  # http://stackoverflow.com/a/17072017
  if [ "$MOTD_ENV" = "development" ]; then
    ## development
    cp .motd.sh ~/.motd.sh
    ## replace http://motd.sh with http://localhost:3000
    sed -i bak -e "s/http:\/\/motd.sh/http:\/\/localhost:3000/" ~/.motd.sh
  else
    ## production
    ## download latest script
    curl -sL "${MOTD_URL}" -o ~/.motd.sh
  fi

  # prompt user for weather (y/n)
  # if (y) then prompt for (auto - lookup by ip) or (enter your city, state/province)
    while read -p "do you want to add the weather forecast to your motd? (y/n)" yn; do
      case $yn in
      [Yy]* )
        echo "please enter a location (e.g. address/city/location/zip)"
        read WEATHER
        WEATHER=`echo "$WEATHER"|sed 's/ /%20/g'`
        sed -i bak -e "s/WEATHER=\"\"/WEATHER=\"$WEATHER\"/" ~/.motd.sh
        # now we want to ask user if they want fahrenheit or celsius
        while read -p "do you want degrees in fahrenheit (y) or celsius (n)? (y/n)" yn; do
            case $yn in
                [Yy]* )
                  echo "you selected fahrenheit!";
                  sed -i bak -e "s/DEGREES=\"\"/DEGREES=\"f\"/" ~/.motd.sh
                  break;;
                [Nn]* )
                  echo "you selected celsius!";
                  sed -i bak -e "s/DEGREES=\"\"/DEGREES=\"c\"/" ~/.motd.sh
                  break;;
                * ) echo "please answer fahrenheit (y) or celsius (n).";;
            esac
        done
        break;;
      [Nn]* )
        break;;
      * )
        echo "please answer yes (y) or no (n).";;
      esac
  done

  # prompt user for stocks (yn)
  # if (y) then prompt for comma delimited stock symbols
  while read -p "do you want to add stock quotes to your motd? (y/n)" yn; do
      case $yn in
          [Yy]* )
            echo "you added stocks!";
            read -p "please enter stocks on NASDAQ separated by a comma (.e.g TSLA,SCTY)" STOCKS
            # strip whitespace from stocks
            # http://unix.stackexchange.com/a/156581
            STOCKS="$(echo "$STOCKS" | tr -d ' ')"
            sed -i bak -e "s/STOCKS=\"\"/STOCKS=\"$STOCKS\"/" ~/.motd.sh
            break;;
          [Nn]* ) break;;
          * ) echo "please answer yes (y) or no (n).";;
      esac
  done

  # prompt user for quotes (y/n)
  while read -p "do you want to add inspirational/motivational quotes to your motd? (y/n)" yn; do
      case $yn in
          [Yy]* )
            echo "you added quotes!";
            sed -i bak -e "s/QUOTES=\"\"/QUOTES=\"y\"/" ~/.motd.sh
            break;;
          [Nn]* )
            sed -i bak -e "s/QUOTES=\"\"/QUOTES=\"n\"/" ~/.motd.sh
            break;;
          * ) echo "please answer yes (y) or no (n).";;
      esac
  done

  # allow script to be executed
  chmod +x ~/.motd.sh

  # detect os
  echo "detecting operating system"

  if [ "$(uname)" == "Darwin" ]; then

    ## mac os x
    echo "detected mac os x"

    if [ \( -z "$ENV" \) -o \( "$ENV" == "development" \) ]; then
      ### copy over plist if we're in development mode
      cp sh.motd.generator.plist ~/Library/LaunchAgents/sh.motd.generator.plist.tmp
    else
      ### otherwise download it
      curl -sL "${PLIST_URL}" -o ~/Library/LaunchAgents/sh.motd.generator.plist.tmp
    fi

    ## replace set user in plist to current user
    cat ~/Library/LaunchAgents/sh.motd.generator.plist.tmp | sed -e "s/USER/$USER/" > ~/Library/LaunchAgents/sh.motd.generator.plist

    ## remove temporary file
    rm ~/Library/LaunchAgents/sh.motd.generator.plist.tmp

    ## schedule jobs
    ## http://nathangrigg.net/2012/07/schedule-jobs-using-launchd/
    launchctl load -w ~/Library/LaunchAgents/sh.motd.generator.plist
    launchctl start sh.motd.generator

    ## give the user a preview by opening terminal
    ## http://stackoverflow.com/a/7177891
    #osascript -e 'tell application "System Events" to keystroke "t" using command down'

    echo "please add (or ensure something similar exists) the following to the top of your ~/.zshrc or ~/.bashrc file"
    echo ""
    echo ""
    echo "# ------ START OF SCRIPT ------"
    echo ""
    echo "# Display MotD"
    echo "if [[ -e \$HOME/.motd ]]; then cat \$HOME/.motd; fi"
    echo ""
    echo "# ------  END OF SCRIPT  ------"
    echo ""
    echo ""
    echo "successfully installed motd.sh"
    bash ~/.motd.sh
    echo "$TERMINAL"
    exit 1

  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    ## linux
    echo "detected linux"

    ## TODO: add support
    echo "linux is not currently supported"
    exit 1

  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    ## windows
    ## TODO: add support
    echo "detected windows"
    echo "windows is not currently supported"
    ## TODO: add github issue for this
    echo ""
    exit 1
  else
    echo "unknown operating system detecting"
    exit 1
  fi
}

motd_install
