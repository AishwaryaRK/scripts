
# motd.sh

dynamic message of the day (~/.motd) generator for :apple: Mac and :penguin: Linux

**[install now][motd-website]**

![motd-gif][motd-gif]
![motd-screenshot][motd-screenshot]

# tips

* want to change the weather, stocks, or another setting without having to re-install?  simply open up `~/.motd.sh` file in your favorite editor (e.g. `vim ~/.motd.sh`), and then modify it per this example below

```diff
-WEATHER="San%20Jose,%20CA"
+WEATHER="San%20Francisco,%20CA"
```

* just make a change to your `~/.motd.sh` file (or simply want your `~/motd` to be updated?  simply execute the shell script:

```bash
sh ~/.motd.sh
```

[motd-gif]: https://media.giphy.com/media/3oEduGuyCpv5gwNkek/giphy.gif
[motd-website]: http://motd.sh
[motd-screenshot]: https://s3.amazonaws.com/filenode/motd.png
