#!/usr/bin/env bash

MOTD_URL="https://raw.githubusercontent.com/messageoftheday/scripts/master/.motd.sh"
PLIST_URL="https://raw.githubusercontent.com/messageoftheday/scripts/master/sh.motd.generator.plist"
MAC_INCLUDE_URL="https://raw.githubusercontent.com/messageoftheday/scripts/master/includes/mac.sh"
LINUX_INCLUDE_URL="https://raw.githubusercontent.com/messageoftheday/scripts/master/includes/linux.sh"
TERMINAL="please open a new terminal window to view the motd"
POST_INSTALL_START="### MOTD Script Start ###"
POST_INSTALL_END="### MOTD Script End ###"

# this defines commands used by the MOTD script
motd_configure()
{
  motd_is_dev()
  {
    if [ "$MOTD_ENV" = "development" ]; then
        return 0 # zero for true, or no error
    else
        return 1 # 1 for false, or error
    fi
  }

  # install the locally bundled version of the MOTD script
  motd_local_update()
  {
    cp .motd.sh ~/.motd.sh
    ## replace http://motd.sh with http://localhost:3000
    #sed -i bak -e "s/http:\/\/motd.sh/http:\/\/localhost:3000/" ~/.motd.sh
  }

  # fetch an MOTD script update from the server
  motd_remote_update()
  {
    ## download latest script
    curl -sL "${MOTD_URL}" -o ~/.motd.sh
  }

  motd_local_mac_include()
  {
    [ ! -e includes/mac.sh ] && echo 'local mac include file not present' && exit 1
    cp includes/mac.sh /tmp/includes/mac.sh
  }

  motd_remote_mac_include()
  {
    curl -sL "${MAC_INCLUDE_URL}" -o /tmp/includes/mac.sh
  }

  motd_fetch_mac_include()
  {
    printf "Fetching mac include..."
    if motd_is_dev; then
        printf "from local..."
        motd_local_mac_include
    else
        printf "from remote..."
        motd_remote_mac_include
    fi
    chmod +x /tmp/includes/mac.sh
    printf "done\n"
  }

  motd_local_linux_include()
  {
    [ ! -e includes/mac.sh ] && echo 'local linux include file not present' && exit 1
    cp includes/linux.sh /tmp/includes/linux.sh
  }

  motd_remote_linux_include()
  {
    curl -sL "${LINUX_INCLUDE_URL}" -o /tmp/includes/linux.sh
  }

  motd_fetch_linux_include()
  {
    printf "Fetching linux include..."
    if motd_is_dev; then
        printf "from local..."
        motd_local_linux_include
    else
        printf "from remote..."
        motd_remote_linux_include
    fi
    chmod +x /tmp/includes/linux.sh
    printf "done\n"
  }

  motd_ensure_includes_dir_exists()
  {
    if [ ! -d "/tmp/includes" ]; then
      echo "Making includes directory"
      mkdir /tmp/includes
    fi
  }

  motd_fetch_includes()
  {
    motd_ensure_includes_dir_exists

    if [ ! -e "/tmp/includes/mac.sh" ]; then
        motd_fetch_mac_include
    fi

    if [ ! -e "/tmp/includes/linux.sh" ]; then
        motd_fetch_linux_include
    fi
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

  motd_configure_stocks()
  {
    sed -i bak -e "s/STOCKS=\"\"/STOCKS=\"$1\"/" ~/.motd.sh
  }

  # ask if installer should configure stocks
  motd_prompt_stocks()
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

  # ask if installer should configure
  motd_prompt_auto_rc()
  {
    while read -p "Automatically update rc file (answering no requires you do it manually)? (y/n)" yn; do
        case $yn in
            [Yy]* )
              while read -p "Bash or Zsh? (bash/zsh)" termtype; do
                case $termtype in
                  zsh )
                    echo "zshrc configured!";
                    motd_configure_auto_rc ~/.zshrc
                    break;;
                  bash )
                    echo "bashrc configured!";
                    motd_configure_auto_rc ~/.bashrc
                    break;;
                  * ) echo "please answer bash or zsh.";;
                esac
              done
              break;;
            [Nn]* )
              motd_post_install_instructions
              break;;
            * ) echo "please answer yes (y) or no (n).";;
        esac
    done
  }

  motd_configure_auto_rc()
  {
      sed -i'.bak' "/$POST_INSTALL_START/,/$POST_INSTALL_END/d" $1

      cat << EOF >> $1
$POST_INSTALL_START

      # Display MotD
      if [[ -e \$HOME/.motd ]]; then cat \$HOME/.motd; fi

$POST_INSTALL_END
EOF
  }

  motd_post_install_instructions()
  {
      cat << EOF
please add (or ensure something similar exists) the following to the top of your ~/.zshrc or ~/.bashrc file

$POST_INSTALL_START

      # Display MotD
      if [[ -e \$HOME/.motd ]]; then cat \$HOME/.motd; fi

$POST_INSTALL_END
EOF
  }

  #update the MOTD script according to environment
  # http://stackoverflow.com/a/3826462
  # http://stackoverflow.com/a/17072017
  motd_init()
  {
    if motd_is_dev; then
      ## development
      motd_local_update
    else
      ## production
      motd_remote_update
    fi
    chmod +x ~/.motd.sh
  }

  motd_configure_os()
  {
    # detect os
    echo "detecting operating system"

    if [ "$(uname)" == "Darwin" ]; then
      ## mac os x
      echo "detected mac os x"
      source /tmp/includes/mac.sh
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      ## linux
      echo "detected linux"
      source /tmp/includes/linux.sh
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
  }


  motd_fetch_includes
  motd_configure_os
  motd_init
}

motd_install()
{
  echo "installing motd.sh"
  motd_configure
  motd_prompt_weather
  motd_prompt_stocks
  motd_prompt_quotes
  motd_setup_generator
  motd_prompt_auto_rc
  echo "successfully installed motd.sh"
  bash ~/.motd.sh
  echo "$TERMINAL"
  exit 0
}

motd_install
