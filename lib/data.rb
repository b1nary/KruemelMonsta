class Data

	##
	# @conns Hash
	# Hash[[ip1,ip2,port1,port2,type]] = [run,slug,moduls,size,last-tick,package-count,modul_meta[]]
	@@conns = Hash.new

	def self.init
		@@conns[:stats] = Hash.new
		@@conns[:stats][:packages] = 0
		@@conns[:stats][:traffic] = 0
		@@conns[:stats][:traffic_tcp] = 0
		@@conns[:stats][:traffic_udp] = 0
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
		mode = :nil
		(mode = :tcp ; @@conns[:stats][:traffic_tcp] += pkt.size) if pkt.tcp?
		(mode = :udp ; @@conns[:stats][:traffic_udp] += pkt.size) if pkt.udp?
		@@conns[:stats][:traffic] += pkt.size
		@@conns[:stats][:packages] += 1

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
				Mods.job x, pkt
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
			@@conns[pkg] = [AUTOWATCH,'',[],0,0,0,{}]

			self.work pkg,pkt
	end

end
