class Data

	##
	# @conns Hash
	# Hash[[ip1,ip2,port1,type]] = [run,slug,moduls,size,last-tick,package-count,modul_meta[]]
	@@conns = Hash.new

	def self.init
		@@conns[:stats] = Hash.new
		self.clear_stat
	end

	def self.clear_stat
		@@conns[:stats][:packages] = 0
		@@conns[:stats][:traffic] = 0
		@@conns[:stats][:traffic_tcp] = 0
		@@conns[:stats][:traffic_udp] = 0
		@@conns[:stats][:time_start] = Time.now.to_i
		@@conns[:stats][:time_lastpkt] = 0
	end

	def self.stats
		@@conns[:stats]
	end

	def self.dump
		##print @@conns.inspect	
		@@conns.each do |k,v|
			puts k[0]+"->"+k[1]+"\t"+k[2].to_s+"/"+k[3].to_s+"\t"+k[4].to_s+" - "+v[0].to_s+" "+v[1].to_s+" "+v[2].to_s+" "+Util.size(v[3])+" "+v[4].to_s if k.class == Array
		end	
	end

	def self.dump_arr
		out = Array.new
		@@conns.each do |k,v|
			out << [k[0],k[1],k[2].to_s,k[3].to_s,k[4].to_s,v[0].to_s,v[1].to_s,v[2].to_s,v[3],v[4].to_s,v[5]] if k.class == Array
		end
		out
	end

	##
	# Get Packages from the Pcap loop and detect if they exist
	# else create them
	def self.push pkt
		mode = :none
		(mode = :tcp ; @@conns[:stats][:traffic_tcp] += pkt.size) if pkt.tcp?
		(mode = :udp ; @@conns[:stats][:traffic_udp] += pkt.size) if pkt.udp?
		@@conns[:stats][:traffic] += pkt.size
		@@conns[:stats][:packages] += 1
		@@conns[:stats][:time_lastpkt] = Time.new.to_i

		sip, dip = pkt.ip_dst.to_s, pkt.ip_src.to_s
		spo, dpo = pkt.sport, pkt.dport

		if @@conns.has_key? [sip,dip,spo,mode]
			self.work [sip,dip,spo,mode], pkt

		elsif @@conns.has_key? [dip,sip,dpo,mode]
			self.work [dip,sip,dpo,mode], pkt

		else
			self.create dip,sip,dpo,spo,mode,pkt

		end

	end

	##
	# Let the known Connection work
	def self.work key, pkt
		if $logall
			$logall_log[key] = [] if $logall_log[key].nil?
			$logall_log[key] << pkt
		end

		@@conns[key][4] = Time.new.to_i
		@@conns[key][5] += 1
		@@conns[key][3] += pkt.size

		if @@conns[key][2].size > 0
			@@conns[key][2].each do |m|
				Mods.job m, pkt
			end
		end

		if @@conns[key][2].size == 0
			x = Mods.try pkt
			if x != nil
				@@conns[key][2] << x
				@@conns[key][1] = Mods.slug( @@conns[key][2][0], pkt )
				Mods.job m, pkt
			end
		end

		if @@conns[key][1] == '' and @@conns[key][2].size > 0
			@@conns[key][1] = Mods.slug( @@conns[key][2][0], pkt )
		end

	end

	##
	# Create new element
	def self.create dip,sip,dpo,spo,mode,pkt
			if dip.match(/^192/) or dip.match(/^10/) or dip.match(/^172/) or dip.match(/^127/)
				pkg = [dip,sip,dpo,mode]
			else
				pkg = [sip,dip,spo,mode]
			end
			@@conns[pkg] = [true,'',[],0,0,0,{}]

			self.work pkg,pkt
	end

	def self.remove cmd
		if !cmd[1].nil?
			help = false
			d = 0
			if cmd[1] == "older"
				if cmd[2].nil?
					help = true
				else
					if Util.numeric? cmd[2]
						@@conns.each do |k,v|
							old = Time.now.to_f-v[4]
							if old > cmd[2].to_i
								@@conns.delete(k)
								d += 1
							end
						end
						if d == 0	
							$mst = :error
							$msg = "No connections removed"
						else
							$mst = :info
							$msg = "#{d} connections removed"
						end
					else
						$mst = :error
						$msg = "Please provide an integer for this Operation"
					end
				end

			elsif cmd[1] == "port" and cmd.size > 2
				@@conns.each do |k,v|
					begin
						if cmd[2].to_i == k[2].to_i
							@@conns.delete(k)
							d += 1
						end
					rescue
					end
				end
				if d == 0	
					$mst = :error
					$msg = "No connections removed"
				else
					$mst = :info
					$msg = "#{d} connections removed"
				end
				
			else
				rm = cmd.join(" ").split('remove ',2)[1] if cmd[0] == "remove"
				rm = cmd.join(" ").split('r ',2)[1] if cmd[0] == "r"
				rm = "?????" if rm.nil?
				@@conns.each do |k,v|
					if k.class == Array
						if k[0].to_s.include? rm or k[1].to_s.include? rm or k[2].to_s.include? rm or k[3].to_s.include? rm or v[1].to_s.include? rm or (!v[2][0].nil? and v[2][0].to_s.include? rm)
							@@conns.delete(k)
							d += 1
						end
					end
				end
				if d == 0	
					$mst = :error
					$msg = "No connections found by \"#{rm}\""
				else
					$mst = :info
					$msg = "#{d} connections removed"
				end
			end
		else
			help = true
		end
		if help
			Cli.help ["Removing","Usage: remove (VALUE|older|port) [seconds|port]","Shortcut: r",""," VALUE\t\tremove by Value"," older [SECS]\tremove all older than X seconds"," port [PORT]\tremove by port"]
		end
	end

end
