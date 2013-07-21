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

$logall = false
$logall_log = {}

$filter = {}
$filter[:on]    = true
$filter[:type]  = :black
$filter[:ips]   = []
$filter[:ports] = []

@sort = :time
@reverse = false
@clist = [
	'list', 'view', 'dns', 'http', 'ip', 'list', 'logall'
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
				$filter[:on] = false
				$mst = :info
				$msg = "Filter cleared and deactivated"
			elsif cmd[1] == "on"
				$mst = :info
				$msg = "Filter activated [Ports #{$filter[:ports].size} | IPs #{$filter[:ips].size}]"
				$filter[:on] = true
			elsif cmd[1] == "off"
				$mst = :info
				$msg = "Filter deactivated [Ports #{$filter[:ports].size} | IPs #{$filter[:ips].size}]"
				$filter[:on] = false
			elsif cmd[1] == "white"
				$mst = :info
				$msg = "Filter mode set to 'whitelist'"
				$filter[:type] = :white
			elsif cmd[1] == "black"
				$mst = :info
				$msg = "Filter mode set to 'blacklist'"
				$filter[:type] = :black
			elsif cmd[1] == "list"
				list = ["Filter list","Modus: #{$filter[:type].to_s}","Active: #{$filter[:on]}","","Ports\t"]
				$filter[:ports].each do |i|
					list << "- #{i}"
				end
				list << ""
				list << "IPs\t"
				$filter[:ips].each do |i|
					list << "- #{i}"
				end
				Cli.help(list)
			else
				f = inp.split('filter ',2)[1] if cmd[0] == "filter"
				f = inp.split('f ',2)[1] if cmd[0] == "f"
				
				type = :ports
				type = :ips   if f.include? '.'

				if f.match(/^-/)
					f = f.gsub('-','')
					if $filter[type].include? f
						$mst = :info
						$msg = "Filter \"#{f}\" removed"
						$filter[type].delete(f)
					else
						$mst = :info
						$msg = "Filter \"#{f}\" does not exist"
					end
				else
					$filter[type] << f.gsub('+','')
					$filter[type].uniq!
					$mst = :info
					$msg = "Filter added \"#{f}\""
				end
			end
		else
			Cli.help [
			"Filtering",
			"filter by connection info",
			"Usage: filter [[+]VALUE|-VALUE|list|clear|on|off|white|black]",
			"Shortcut: f",
			"",
			"A filter can eather be a whitelist or a blacklist.\t",
			"The whitelist filters all but the filter list\t",
			"The Blacklist does the opposite (default)\t",
			"",
			"Add or remove item from filter\t",
			"filter +80         # adds port 80",
			"filter 6667        # adds to, also without +",
			"filter -127.0.0.1  # removes ip from filter",
			"",
			"List filter\t",
			"filter list",
			"",
			"Set black/white list\t",
			"filter black|white",
			"",
			"Clear filter\t",
			"filter clear"]
			con = false
		end

	#
	# Removing
	#
	elsif cmd[0] == "remove" or cmd[0] == "r"
		Data.remove cmd

	#
	# About
	#
	elsif cmd[0] == "about"
		Cli.help ["KrumelMonsta","a Ruby-Pcap based network-traffic sniffer","","Created by Roman Pramberger\t","        roman@pramberger.ch","","License: MIT\t"]

	#
	# Log all
	#
	elsif cmd[0] == "logall" or cmd[0] == "la"
		if !cmd[1].nil? and cmd[1] == 'clear'
			$logall_log = {}
			$mst = :info
			$msg = "Log-All log cleared"
		elsif !cmd[1].nil? and cmd[1] == 'stat'
			c = 0
			$logall_log.each do |x|
				c += x.size
			end
			$mst = :info
			$msg = "[Log-All] #{$logall_log.size} connections and #{c} packages logged"
		elsif !cmd[1].nil? and cmd[1] == 'list'
			if cmd[2].nil?
				$logall_log.each do |connection|
					p connection[0]
					connection[1].each do |paket|
						Cli.print_pkg paket
					end
				end
			end
		else
			if $logall == true
				$logall = false
				$mst = :info
				$msg = "Log-All deactivated"
			else
				$logall = true
				$mst = :info
				$msg = "Log-All activated"
			end
		end

	#
	# Stats
	#
	elsif cmd[0] == "stats" or cmd[0] == "stat"
		if !cmd[1].nil? and cmd[1] == "clear"
			Data.clear_stat
			Cli.list_stat "Session Stats", Data.stats
			$mst = :info
			$msg = "Session Stats cleared"
		else
			Cli.list_stat "Session Stats", Data.stats
		end
	else

		if Mods.exist? cmd[0]
			begin
				Mods.cmd cmd
			rescue
			end
		else
			interface.conns_format Data.dump_arr,@sort,@reverse,$filter if con
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
