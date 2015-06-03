#!/usr/bin/env bash

MOTD_URL="https://raw.githubusercontent.com/messageoftheday/scripts/master/.motd.sh"
PLIST_URL="https://raw.githubusercontent.com/messageoftheday/scripts/master/sh.motd.generator.plist"
MAC_INCLUDE_URL="https://raw.githubusercontent.com/shadesoflight/scripts/dry-prep/includes/mac.sh"
LINUX_INCLUDE_URL="https://raw.githubusercontent.com/shadesoflight/scripts/dry-prep/includes/linux.sh"
TERMINAL="please open a new terminal window to view the motd"

# this defines commands used by the MOTD script
motd_configure()
{
  # install the locally bundled version of the MOTD script
  motd_local_update()
  {
    cp .motd.sh ~/.motd.sh
    ## replace http://motd.sh with http://localhost:3000
    sed -i bak -e "s/http:\/\/motd.sh/http:\/\/localhost:3000/" ~/.motd.sh
  }

  # fetch an MOTD script update from the server
  motd_remote_update()
  {
    ## download latest script
    curl -sL "${MOTD_URL}" -o ~/.motd.sh
  }

  #update the MOTD script according to environment
  # http://stackoverflow.com/a/3826462
  # http://stackoverflow.com/a/17072017
  motd_update()
  {
    if [ "$MOTD_ENV" = "development" ]; then
      ## development
      motd_local_update
    else
      ## production
      motd_remote_update
    fi
  }

  # allow script to be executed
  motd_set_executable()
  {
    chmod +x ~/.motd.sh
  }

  motd_configure_weather_address()
  {
    sed -i bak -e "s/WEATHER=\"\"/WEATHER=\"$1\"/" ~/.motd.sh
  }

  motd_configure_weather_degrees()
  {
    sed -i bak -e "s/DEGREES=\"\"/DEGREES=\"$1\"/" ~/.motd.sh
  }

  # ask if installer should configure weather
  motd_prompt_weather()
  {
    # prompt user for weather (y/n)
    # if (y) then prompt for (auto - lookup by ip) or (enter your city, state/province)
    while read -p "do you want to add the weather forecast to your motd? (y/n)" yn; do
      case $yn in
      [Yy]* )
        echo "please enter a location (e.g. address/city/location/zip)"
        read WEATHER
        WEATHER=`echo "$WEATHER"|sed 's/ /%20/g'`
        motd_configure_weather_address $WEATHER
        # now we want to ask user if they want fahrenheit or celsius
        while read -p "do you want degrees in fahrenheit (y) or celsius (n)? (y/n)" yn; do
            case $yn in
                [Yy]* )
                  echo "you selected fahrenheit!";
                  motd_configure_weather_degrees f
                  break;;
                [Nn]* )
                  echo "you selected celsius!";
                  motd_configure_weather_degrees c
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
  }

  motd_configure_stock()
  {
    sed -i bak -e "s/STOCKS=\"\"/STOCKS=\"$1\"/" ~/.motd.sh
  }

  # ask if installer should configure stocks
  motd_prompt_stock()
  {
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
              motd_configure_stocks $STOCKS
              break;;
            [Nn]* ) break;;
            * ) echo "please answer yes (y) or no (n).";;
        esac
    done
  }

  motd_configure_quotes()
  {
    sed -i bak -e "s/QUOTES=\"\"/QUOTES=\"$1\"/" ~/.motd.sh
  }

  # ask if installer should configure 
  motd_prompt_quotes()
  {
    # prompt user for quotes (y/n)
    while read -p "do you want to add inspirational/motivational quotes to your motd? (y/n)" yn; do
        case $yn in
            [Yy]* )
              echo "you added quotes!";
              motd_configure_quotes y
              break;;
            [Nn]* )
              motd_configure_quotes n
              break;;
            * ) echo "please answer yes (y) or no (n).";;
        esac
    done
  }

  motd_fetch_includes()
  {
    if [ ! -d "includes" ]; then
      echo "Making includes directory"
      mkdir includes
    fi

    if [ ! -e "includes/mac.sh" ]; then
      printf "Fetching mac include..."
      curl -sL "${MAC_INCLUDE_URL}" -o includes/mac.sh
      printf "done\n"
    fi

    if [ ! -e "includes/linux.sh" ]; then
      printf "Fetching linux include..."
      curl -sL "${LINUX_INCLUDE_URL}" -o includes/linux.sh
      printf "done\n"
    fi
  }

  motd_configure_os()
  {
    # detect os
    echo "detecting operating system"

    if [ "$(uname)" == "Darwin" ]; then
      ## mac os x
      echo "detected mac os x"
      source includes/mac.sh
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      ## linux
      echo "detected linux"
      source includes/linux.sh
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

  motd_fetch_includes
  motd_configure_os
  motd_update_motd
}

motd_install()
{
  echo "installing motd.sh"
  motd_configure
  motd_prompt_weather
  motd_prompt_stock
  motd_prompt_inspiration
}

motd_install
