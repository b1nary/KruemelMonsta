#!/usr/bin/env ruby
$LOAD_PATH.unshift File.dirname(__FILE__)
Dir["mods/*.rb"].each {|file| require file }

require 'rubygems'
require 'optparse'
require 'pcaplet'
require "base64"
require 'zlib'
require 'readline'
require 'stringio'

require 'lib/data'
require 'lib/kmpcap'
require 'lib/util'
require 'lib/mods'
require 'lib/proxy'

require 'mods/interface/cli'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: krumelmonsta [options]"

	opts.separator ""

	opts.on("-d", "--device [device]", "Device to liston to (default: best fitting)") do |v|
		options[:device] = v
	end

	opts.on("-f", "--filter [FILTER]", "Use a Pcap Filter string (default: tcp and udp)") do |v|
		options[:filter] = v
	end

	opts.on("-t", "--theme [NAME]", "Load specific theme from mods/themes") do |v|
		options[:theme] = v
	end

	opts.separator ""

#	options[:save] = false
#	opts.on("-s", "--save [NAME]", "Safe to named session") do |v|
#		options[:save] = v
#	end
#
#	opts.on("-l", "--load [NAME]", "Load given session") do |v|
#		options[:load] = v
#	end

#	opts.separator ""

#	opts.on("-W", "--web [PORT]", "Start web interface on given port") do |v|
#		options[:web] = v
#	end

#	opts.on("-D", "--demonize", "Start programm as deamon") do |v|
#		options[:demon] = v
#	end
end.parse!

if options[:theme].nil?
require 'mods/themes/default'
else
require 'mods/themes/'+options[:theme]
end

STDOUT.sync = true

KMPcap.init options[:device], options[:filter]

def _readline
	line = Readline.readline(Util._background(COLOR_HEADER_BACKGROUND)+''+Util._foreground(COLOR_HEADER_TEXT)+' > '+Util._foreground(254), true)
	return nil if line.nil?
	if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
		Readline::HISTORY.pop
	end
	line
end

Data.init
Util.init
Mods.init
interface = Cli.new

@sort = :time
@reverse = false
@filter = ''
@clist = [
	'list', 'view', 'dns', 'http', 'ip', 'list'
].sort
comp = proc { |s| @clist.grep( /^#{Regexp.escape(s)}/ ) }
Readline.completion_append_character = " "
Readline.completion_proc = comp
interface.header
while inp = _readline

	interface.header
	$msg = nil
	$mst = :info
	cmd = inp.split(" ")
	con = true
	
	#
	# Sorting
	#
	if cmd[0] == "sort" or cmd[0] == "s"
		if cmd[1] == "time"; @sort = :time; did = true
		elsif cmd[1] == "ip1"; @sort = :ip1; did = true
		elsif cmd[1] == "ip2"; @sort = :ip2; did = true
		elsif cmd[1] == "ip"; @sort = :ip2; did = true
		elsif cmd[1] == "port"; @sort = :port ; did = true
		elsif cmd[1] == "type"; @sort = :type; did = true
		elsif cmd[1] == "slug" or cmd[1] == "desc" or cmd[1] == "name"; @sort = :slug; did = true
		elsif cmd[1] == "traffic" or cmd[1] == "size"; @sort = :traffic ; did = true
		elsif cmd[1] == "packages" or (!cmd[1].nil? and cmd[1].include? 'packa'); @sort = :packages; did = true
		else
			Cli.help ["Sorting","sort by several filters:","Usage: sort FILTER [reverse]","Shortcut: s",""," ip1\t\tfirst ip"," ip2\t\tsecond ip [also: ip]"," port\t\tby port"," type\t\ttcp/udp/..."," slug\t\tthe info string [also: name, desc]"," traffic\tconnections traffic use [also: size]"," packages\tpackage count [also: packa*]","","Reverse","use true, t or 1 as second parameter to reverse the list\t"]
			con = false
		end
		if !did.nil?
			if cmd[2] == "true" or cmd[2] == "t" or cmd[2] == "1"
				@reverse = true
			else
				@reverse = false
			end
			$msg = "Sorted by: \"#{@sort.to_s}\" "
			$msg = $msg+"reverse! " if @reverse
			$mst = :info
		end

	#
	# Filtering
	#
	elsif cmd[0] == "filter" or cmd[0] == "f"
		if !cmd[1].nil?
			if cmd[1] == "clear" or cmd[1] == "del"
				@filter = ''
				$mst = :info
				$msg = "Filter cleared"
			else
				f = inp.split('filter ',2)[1] if cmd[0] == "filter"
				f = inp.split('f ',2)[1] if cmd[0] == "f"
				@filter = f
				$mst = :info
				$msg = "Filter set to: \"#{f}\""
			end
		else
			Cli.help ["Filtering","filter the package info","Usage: filter some values","Shortcut: f","","There is nothing special around here.\t","Just type filter followed by your filter value\t","","You can clear the filter easily\t","filter clear"]
			con = false
		end

	#
	# Removing
	#
	elsif cmd[0] == "remove" or cmd[0] == "r"
		Data.remove cmd

	else

		if Mods.exist? cmd[0]
			begin
				Mods.cmd cmd
			rescue
			end
		else
			interface.conns_format Data.dump_arr,@sort,@reverse,@filter if con
		end

	end

	puts "\n\n"
	if !$msg.nil?
		if $mst == :info
		Util.background COLOR_INFO_BACKGROUND
		Util.foreground COLOR_INFO_FOREGROUND
		elsif $mst == :error
		Util.background COLOR_ERROR_BACKGROUND
		Util.foreground COLOR_ERROR_FOREGROUND
		end
		str = ":: #{$msg} "
		line = ' '*(Util.cols-str.size-2)
		puts "#{str}#{line}::"+"\x1b[0m"
		Util.background COLOR_CONTENT_BACKGROUND
		Util.foreground COLOR_CONTENT_1
		$msg = nil
		print " "
	end
end
