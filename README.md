KrümelMonsta
=============

RubyPcap based Network Traffic filter designed to make relevant Information easy acessable.
It's not very useful yet but it can be used for http package anaylzing already.

**Note that this software is made for Unix boxes**

## Install
There is no need to really install it.

It works recursive from the working directory and needs a few depencies like ruby and optionally the WEBrick gem

First get the files:

>  git clone https://b1nary@github.com/b1nary/KruemelMonsta.git

Install depencies:

> sudo gem install pcap

If you want to use the HTTP Proxy

> sudo gem install webrick

## Use

> cd /path/to/krümelmonsta
> sudo ruby run.rb --device eth0

Alternative:

> sudo ruby run.rb --help

## Commands
*  list

   > List connections
*  sort VALUE 

   > Sort connections by value (try "sort" to get more help)
*  filter VALUE

   > Set filter for connection list
