class MOD_irc

	def self.strings
		[['hex_PING','hex_LAG'],['hex_PONG','hex_LAG'],[':End of WHO list']]
	end

	def self.slug d
		if d.raw_data.include? '352'
			x = d.raw_data.split(" 352 ")
			return "[IRC] Nick: "+x[1].split(' ')[0]+" - Server: "+d.ip_src.to_s
		end
		return ''
	end

	def self.cmd

	end

end
