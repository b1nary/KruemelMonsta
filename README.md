![Example KrümelMonsta Screen](http://i48.tinypic.com/2mhdenp.png)
KrümelMonsta
=============

## BEWARE: Mostly broken atm, i will fix it when the depencies seem stable again

Ruby-Pcap based Network Traffic sniffer designed to make relevant Information easy acessable.
Its made to give a new experience in Traffic Sniffing, you finally wont see a flood of nonsense packages. You get each connection but you only get detailed information if its useful (and there is a modul for it). The HTTP Modul makes it easy to view all HTTP Request, you can start a Proxy directly to use all or a set of the captured cookies. And yes its extendable, so extend it to do whatever you want. 


**Note that this software is made for Unix boxes only and wont work with Ruby 1.9**

Also pcap itself seems buggy like hell on some machines/versions... i dont know why, it worked fine on mine. Try to remove the 'site_ruby' files in the error message if you have the missing pointers error.

## Install
There is no need to really install it.

It works recursive from the working directory and needs a few depencies like ruby and optionally the WEBrick gem

First get the files:

>  git clone https://github.com/b1nary/KruemelMonsta.git

Install depencies:

> sudo apt-get install libpcap-ruby1.8

If you want to use the HTTP Proxy

> sudo gem install webrick

## Use it

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

## Themes
Yes its Themeable. It just come to this, it doesnt really make it better.

![Example KrümelMonsta Theme Screen](http://i50.tinypic.com/2lu8f8w.png)

## Author

b1nary

> I've done this as a fun project and to increase my skills in networking.

> Dont blame me for any problems

## License

i dont plan to use any known license. Just follow those simple rules:

*  If you publish it in any way, link to this github
*  Dont sell it. You can give it for free any time in association with rule 1
*  Else, do whatever you want
