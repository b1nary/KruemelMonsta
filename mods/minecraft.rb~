##
# Only detects join events
class MOD_minecraft

	def self.strings
		[['joinserver.jsp','session.minecraft.net']]
	end

	def self.slug d
		user = d.raw_data.split("?user",2)[1].split("sessionId",2)[0].slice(1..-2)
		return "[MINECRAFT] #{user}"
		return ''
	end

	def self.cmd cmd
		Cli.help ["Minecraft Modul","No Commands aviable","","Detects Minecraft JOIN Events.\t","No sniffing currently...\t",]
	end

end
