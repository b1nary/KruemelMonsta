class Cli

	def initialize

	end

	def draw
		self.header
	end

	def header
		self.clear_screen
	  Util.background COLOR_HEADER_BACKGROUND
	  Util.foreground COLOR_HEADER_TEXT
		puts ' '*Util.cols
		puts  ' 88  dP 88""Yb 88   88 8b    d8 888888 88     8b    d8  dP"Yb  88b 88 .dP"Y8 888888    db'
		puts  ' 88odP  88__dP 88   88 88b  d88 88__   88     88b  d88 dP   Yb 88Yb88 `Ybo."   88     dPYb   '
		puts  ' 88"Yb  88"Yb  Y8   8P 88YbdP88 88""   88  .o 88YbdP88 Yb   dP 88 Y88 o.`Y8b   88    dP__Yb  '
		print ' 88  Yb 88  Yb  YbodP  88 YY 88 888888 88ood8 88 YY 88  YbodP  88  Y8 8bodP    88   dP""""Yb '
	  Util.foreground COLOR_HEADER_VERSION
		puts " V #{$version}"
	  Util.foreground COLOR_HEADER_LINE
		print '='*Util.cols
	  Util.background COLOR_CONTENT_BACKGROUND
	end

	def clear_screen
		print "\e[2J" # \e[f
	end

	def conns_format arr, order = :time, reverse = false, filter = ''
		arr.sort! {|x,y| y[9].to_i <=> x[9].to_i } if order == :time 
		arr.sort! {|x,y| y[0].split('.',2)[0].to_i <=> x[0].split('.',2)[0].to_i } if order == :ip1
		arr.sort! {|x,y| y[1].split('.',2)[0].to_i <=> x[1].split('.',2)[0].to_i } if order == :ip2
		arr.sort! {|x,y| y[2].to_i <=> x[2].to_i } if order == :port
		arr.sort! {|x,y| y[3] <=> x[3] } if order == :type
		arr.sort! {|x,y| y[6] <=> x[6] } if order == :slug
		arr.sort! {|x,y| y[8] <=> x[8] } if order == :traffic
		arr.sort! {|x,y| y[10] <=> x[10] } if order == :packages
		arr.reverse! if reverse
		arr.each do |l|
			begin
				if filter[:on] == false or (
						(filter[:type] == :white and (
							filter[:ports].include? l[2] or
							filter[:ips].include? l[0] or filter[:ips].include? l[1]
						)) or 
						(filter[:type] == :black and (
							!filter[:ports].include? l[2] and
							!filter[:ips].include? l[0] and !filter[:ips].include? l[1]
						))
					) 
				print ' '
				# slug l[4]
				Util.foreground COLOR_CONTENT_1
				print Util.str_size(l[0],14)
				Util.foreground COLOR_CONTENT_8
				print " > "
				Util.foreground COLOR_CONTENT_1
				print Util.str_size(l[1],16)
				Util.foreground COLOR_CONTENT_2
				print Util.str_size(l[2]+"/"+l[3],11)
				Util.foreground COLOR_CONTENT_4
				print Util.str_size(Util.size(l[8]),9)
				Util.foreground COLOR_CONTENT_5
				print Util.str_size(Util.time(l[9].to_i),6)
				Util.foreground COLOR_CONTENT_6
				print Util.str_size("#{l[10]}",7)
				Util.foreground COLOR_CONTENT_7
				print Util.str_size(l[6],Util.cols-68)
				print "\n"
			end
			rescue
			end
		end
	end

	def self.help arr
		arr.each_with_index do |l,i|
			if i == 0
				Util.foreground COLOR_CONTENT_1
			elsif l.include? "\t"
				Util.foreground COLOR_CONTENT_2
			elsif l.include? "Usage: " or l.include? "Shortcut: "
				Util.foreground COLOR_CONTENT_5
			else
				Util.foreground COLOR_CONTENT_3
			end
			puts " #{l}"
		end
	end

	def self.arr_format arr
		arr.each do |i|
			i.each do |x|
				print x+"\t"
			end
			print "\n"
		end
	end
	
	def self.print_pkg pkg 
		Util.foreground COLOR_CONTENT_3
		p pkg.raw_data
		Util.foreground COLOR_CONTENT_4
		p Util.dump_pkt(pkg)
		Util.foreground COLOR_CONTENT_5
		p Util.to_hex(pkg)
		Util.foreground COLOR_CONTENT_2
	end

	##
	# Ugly in code, but sexy in look
	# (this applys also to most of the other code)
	def self.list_stat title, hash
		Util.foreground COLOR_CONTENT_1
		puts " #{title}\n\n"

		Util.foreground COLOR_CONTENT_2
		print Util.str_size "  Packages",16
		Util.foreground COLOR_CONTENT_3
		print " => "
		Util.foreground COLOR_CONTENT_5
		print hash[:packages].to_s+"\n"

		Util.foreground COLOR_CONTENT_2
		print Util.str_size "  Session start",16
		Util.foreground COLOR_CONTENT_3
		print " => "
		Util.foreground COLOR_CONTENT_5
		print Util.time(hash[:time_start])+"\n"

		Util.foreground COLOR_CONTENT_2
		print Util.str_size "  Last Package",16
		Util.foreground COLOR_CONTENT_3
		print " => "
		Util.foreground COLOR_CONTENT_5
		print Util.time(hash[:time_lastpkt])+"\n"

		puts ""

		Util.foreground COLOR_CONTENT_2
		print Util.str_size "  Traffic (all)",16
		Util.foreground COLOR_CONTENT_3
		print " => "
		Util.foreground COLOR_CONTENT_5
		print Util.size(hash[:traffic])+"\n"

		Util.foreground COLOR_CONTENT_2
		print Util.str_size "  Traffic (tcp)",16
		Util.foreground COLOR_CONTENT_3
		print " => "
		Util.foreground COLOR_CONTENT_5
		print Util.size(hash[:traffic_tcp])+"\n"
		
		Util.foreground COLOR_CONTENT_2
		print Util.str_size "  Traffic (udp)",16
		Util.foreground COLOR_CONTENT_3
		print " => "
		Util.foreground COLOR_CONTENT_5
		print Util.size(hash[:traffic_udp])+"\n"
	end

	def self.list_2col title, hash
		Util.foreground COLOR_CONTENT_1
		puts " #{title}\n\n"
		hash.each do |k,v|
			Util.foreground COLOR_CONTENT_2
			print Util.str_size "  #{k}",14
			Util.foreground COLOR_CONTENT_3
			print " => "
			Util.foreground COLOR_CONTENT_5
			print v+"\n"
		end
	end

	def self.list_http arr, filt = nil
		arr.each_with_index do |i,ii|
			if filt.nil? or (i[:host].include?(filt) or i[:request].include?(filt) or i[:method].include?(filt) or (!i[:cookie].nil? and i[:cookie].include?(filt)) or (!i[:referer].nil? and i[:referer].include?(filt)))
				print " "
				Util.foreground COLOR_CONTENT_4
				print Util.str_size ii.to_s, 5
				Util.foreground COLOR_CONTENT_1
				print " "
				print Util.str_size i[:host], 20
				Util.foreground COLOR_CONTENT_3
				print " "+Util.str_size(i[:method], 5)
				Util.foreground COLOR_CONTENT_2
				info = " "
				info = "#{info}[PASS?]" if i[:request].include? 'pass' or i[:request].include? 'pw' or i[:request].include? 'login'
				info = "#{info}[COOKIE]" if !i[:cookie].nil?
				print info
				Util.foreground COLOR_CONTENT_5
				print " "
				print Util.str_size i[:request], (Util.cols-35-info.size)
				print "\n"
			end
		end
	end

	def _clear
		print "\x1b[0m"
	end

end
