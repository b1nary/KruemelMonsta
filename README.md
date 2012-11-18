![Example KrümelMonsta Screen](http://i48.tinypic.com/2mhdenp.png)
KrümelMonsta
=============

Ruby-Pcap based Network Traffic sniffer designed to make relevant Information easy acessable.
Its made to give a new experience in Traffic Sniffing, you finally wont see a flood of nonsense packages. You get each connection but you only get detailed information if its useful (and there is a modul for it). The HTTP Modul makes it easy to view all HTTP Request, you can start a Proxy directly to use all or a set of the captured cookies. And yes its extendable, so extend it to do whatever you want. 


**Note that this software is made for Unix boxes only**

## Install
There is no need to really install it.

It works recursive from the working directory and needs a few depencies like ruby and optionally the WEBrick gem

### Install depencies:

libpcap-dev

> sudo apt-get install libpcap-dev

https://github.com/ahobson/ruby-pcap

> git clone https://github.com/ahobson/ruby-pcap

> cd ruby-pcap

> rake build

> gem install pcap-*.gem

### Get the KruemelMonsta:

>  git clone https://github.com/b1nary/KruemelMonsta.git


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

>Copyright (c) 2011 b1nary

>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
