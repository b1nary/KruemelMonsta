KrümelMonsta
=============

RubyPcap based Network Traffic sniffer designed to make relevant Information easy acessable.
It's not very useful yet but it can be used for http package anaylzing already. The idea behind the script is to make a new experience network sniffer. On its own it just handles your local traffic but with the help of ettercap or similar you can use a script like this for many many purposes. Also note its made for gatherling Information it cant infect or manipulate Packets, but you can write additional Moduls to get several types of Information.

![Example KrümelMonsta Screen](http://i48.tinypic.com/2mhdenp.png)

**Note that this software is made for Unix boxes**

## Install
There is no need to really install it.

It works recursive from the working directory and needs a few depencies like ruby and optionally the WEBrick gem

First get the files:

>  git clone https://github.com/b1nary/KruemelMonsta.git

Install depencies:

> sudo gem install pcap

If you want to use the HTTP Proxy

> sudo gem install webrick

## Use

> cd /path/to/KruemelMonsta

> sudo ruby run.rb --device eth0

Alternative:

> sudo ruby run.rb --help

## Commands

All Commands provide in-script help textes thereself just try around a bit.

*  List connections

   > list
*  Sorting by VALUE, true for reverse

   > sort (time|ip1|ip2|port|type|slug|traffic|packages) [true|]
*  Set/Clear Filter

   > filter (VALUE|clear)
*  Remove connections

   > remove (VALUE|older) [seconds]

*  Session Statistic

   > stat [clear]

## Mods

#### MOD_http

*  List saved HTTP Requests
 
   > http list

*  Count of HTTP Requests

   > http size

*  Set/clear filter for http list

   > http filter (VALUE|clear)

*  Remove content by value

   > http remove VALUE

*  Start/Stop/Update proxy

   > http proxy (PORT|stop|update)

#### MOD_irc

*  Show IRC log

   > irc list
*  Clear IRC log

   > irc clear
*  Set/Clear filter

   > irc filter (VALUE|clear)
*  Remove by value

   > irc remove VALUE

#### MOD_torrent
Detects Torrent connections

*  No commands aviable

#### MOD_msn
Detects MSN connections

*  No commands aviable
*  tested only with aMSN

#### MOD_minecraft
Detects Minecraft joins

*  No commands aviable

## Author

b1nary

> I've done this as a fun project and to increase my skills in networking.

> Dont blame me for any problems

## License

i dont plan to use any known license. Just follow those simple rules:

*  If you publish it in any way, link to this github
*  Dont sell it. Except in form of a "package" but association in rule 1
*  Else, do whatever you want
