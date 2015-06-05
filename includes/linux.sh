#!/usr/bin/env bash

motd_setup_generator()
{
  CRONJOB="0 * * * * /home/$USER/.motd.sh"
  CRONTAB=`crontab -l`

  if echo $CRONTAB | grep "no crontab"; then
    crontab -i
    CRONTAB=`crontab -l`
  fi

  # crontab -l lists the current crontab jobs,
  # cat prints it
  # echo prints the new command
  # and crontab - adds all the printed stuff into the crontab file.
  (echo $CRONTAB | { grep -v "$CRONJOB"; echo "$CRONJOB"; }) | crontab -
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
