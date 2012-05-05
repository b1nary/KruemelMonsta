##
# Actually only tested with the aMSN client :3
class MOD_msn

	def self.strings
		[[' MSNMSGR ','CVR'],['VER','MSNP','CVR']]
	end

	def self.slug d
		if d.raw_data.include? 'msmsgs'
			name = d.raw_data.split('msmsgs ')[1].split(" ")[0].split("\n")[0].chomp()
			return "[MSN] "+name
		elsif d.raw_data.include? 'USR' and d.raw_data.include? 'SSO I '
			name = d.raw_data.split('SSO I ')[1].split(" ")[0].chomp()
			return "[MSN] "+name
		end
		return ''
	end

	def self.cmd cmd
		Cli.help ["MSN Modul","No Commands aviable","","Detects MSN Connections.\t","No sniffing currently...\t","","currently only tested with aMSN"]
	end

end
