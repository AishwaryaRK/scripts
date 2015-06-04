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
