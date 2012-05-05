class MOD_irc

	@@irc = Array.new
	@@filter = nil

	def self.strings
		[['PING','LAG'],['PONG','LAG'],[':End of WHO list'],['PRIVMSG #','!',':']]
	end

	def self.slug d
		if d.raw_data.include? '352'
			x = d.raw_data.split(" 352 ")
			return "[IRC] Nick: "+x[1].split(' ')[0]+" - Server: "+d.ip_src.to_s
		end
		return ''
	end

	def self.cmd cmd
		list = false

		if cmd[0] == "clear"
			@@irc = Array.new
			$mst = :info
			$msg = "[IRC] log cleared"

		elsif cmd[0] == "filter" and cmd.size > 1
			if cmd[1] == "clear"
				@@filter = nil
				$mst = :info
				$msg = "[IRC] filter cleared"
			else
				@@filter = cmd.join(" ").gsub("filter ","")
				$mst = :info
				$msg = "[IRC] filter set to \"#{@@filter}\""
			end
			list = true

		elsif cmd[0] == "remove" and cmd.size > 1
			rm = cmd.join(" ").gsub("remove ","")
			rx = 0
			@@irc.each_with_index do |x,i|
				if x[0].include? rm or x[1].include? rm or x[2].include? rm
					@@irc.delete_at(i)
					rx += 1
				end
			end

			if rx == 0
				$mst = :error
				$msg = "[IRC] Nothing found to remove by \"#{rm}\""
			else
				$mst = :info
				$msg = "[IRC] #{rx} elements removed"
			end
			list = true

		elsif cmd[0] != "list"
			Cli.help ["IRC Modul","Usage: irc COMMAND [PARAMETER]","","Commands:"," list\t\t\tlist IRC log"," clear\t\t\tclear IRC log"," filter (VALUE|clear)\tSet/Clear filter for log"," remove VALUE\t\tremove by value"]
		end

		if cmd[0] == "list" or list
			@@irc.each do |i|
				if @@filter.nil? or (i[0].include? @@filter or i[1].include? @@filter or i[2].include? @@filter)
					Util.foreground COLOR_CONTENT_1
					print ' '
					print Util.str_size i[0], 16
					print ' '
					Util.foreground COLOR_CONTENT_2
					print Util.str_size i[1], 11
					print ' '
					Util.foreground COLOR_CONTENT_4
					print Util.str_size i[2], (Util.cols-31)
					print "\n"
				end
			end
		end

	end

	def self.job pkt
		if pkt.raw_data.include? ' PRIVMSG #'
			name = pkt.raw_data.split("PRIVMSG")[0].split(":")[1].gsub("!"," ").chomp()
			room = pkt.raw_data.split("PRIVMSG ")[1].split(" :",2)[0].chomp()
			mess = pkt.raw_data.split("PRIVMSG ")[1].split(" :",2)[1].chomp()
			@@irc << [name,room,mess]
		elsif pkt.raw_data.include? 'PRIVMSG #'
			name = "# VICTIM #"
			room = pkt.raw_data.split("PRIVMSG ")[1].split(" :",2)[0].chomp()
			mess = pkt.raw_data.split("PRIVMSG ")[1].split(" :",2)[1].chomp()
			@@irc << [name,room,mess]
		elsif pkt.raw_data.include? ' JOIN '
			name = pkt.raw_data.split(" JOIN")[0].split(":")[1].gsub("!"," ").chomp()
			room = pkt.raw_data.split("JOIN :")[1].chomp()
			mess = ">> JOINED"
			@@irc << [name,room,mess]
		elsif pkt.raw_data.include? ' PART '
			name = pkt.raw_data.split(" PART")[0].split(":")[1].gsub("!"," ").chomp()
			room = pkt.raw_data.split("PART :")[1].chomp()
			mess = ">> LEAVED"
			@@irc << [name,room,mess]
		end
	end

end
