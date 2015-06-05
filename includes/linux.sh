#!/usr/bin/env bash

motd_setup_generator()
{
  CRONTIME='0 * * * *'
  CRONCMD="/home/$USER/.motd.sh"
  CRONJOB="${CRONTIME} ${CRONCMD}"

  ((crontab -l | grep -v $CRONCMD); echo "${CRONJOB}") | crontab -
}

motd_configure_weather_address()
{
  sed -i'.bak' -e "s/WEATHER=\"\"/WEATHER=\"$1\"/" ~/.motd.sh
}

motd_configure_weather_degrees()
{
  sed -i'.bak' -e "s/DEGREES=\"\"/DEGREES=\"$1\"/" ~/.motd.sh
}

motd_configure_stocks()
{
  sed -i'.bak' -e "s/STOCKS=\"\"/STOCKS=\"$1\"/" ~/.motd.sh
}

motd_configure_quotes()
{
  sed -i'.bak' -e "s/QUOTES=\"\"/QUOTES=\"$1\"/" ~/.motd.sh
}
