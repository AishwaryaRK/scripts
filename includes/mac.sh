motd_setup_generator()
{
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
    launchctl start ../sh.motd.generator

    ## give the user a preview by opening terminal
    ## http://stackoverflow.com/a/7177891
    #osascript -e 'tell application "System Events" to keystroke "t" using command down'
}

motd_post_install_instructions()
{
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
}
