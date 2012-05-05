class MOD_torrent

	def self.strings
		[['q4:ping1:t4'],[':ad2:id20:'],['find_node1:t4:'],[':q9:get_peers1:']]
	end

	def self.slug d
		ip = d.ip_src.to_s 
		ip = d.ip_dst.to_s if d.ip_dst.to_s.match(/^127/) or d.ip_dst.to_s.match(/^172/) or d.ip_dst.to_s.match(/^10/) or d.ip_dst.to_s.match(/^192/)
		return "[TORRENT] "+ip
		return ''
	end

	def self.cmd cmd
		Cli.help ["Torrent Modul","No Commands aviable","","Detects Torrent connection's"]
	end

end
