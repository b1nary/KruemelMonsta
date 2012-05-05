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

*  list

   > List connections
*  sort (time|ip1|ip2|port|type|slug|traffic|packages) [true|]

   > Sort connections by value, true for reverse
*  filter (VALUE|clear)

   > Set filter for connection list

## Mods

#### http

*  http list
 
   > List saved HTTP Requests

*  http size

   > Count of HTTP Requests

*  http filter (VALUE|clear)

   > Set/clear filter for http list

*  http remove VALUE

   > Remove content by value

*  http proxy (PORT|stop|update)

   > Start/Stop/Update proxy
