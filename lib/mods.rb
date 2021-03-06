class Mods

	@@mods = Array.new

	def self.init
		Dir.glob("mods/*.rb") {|filename|
			name = filename.gsub("mods/","").gsub(".rb","")
			require "mods/#{name}"
  		@@mods << name
		}
	end

	##
	# return whole modul, to use static OR instance
	def self.try pkt
		@@mods.each do |m|
			mod = "MOD_#{m}"
			if eval(mod).respond_to? 'strings'
				eval(mod).strings.each do |mx|
					out = nil
					mx.each do |my|
						if my.match(/^hex_/) and Util.to_hex(pkt).include? my.gsub('hex_','') and (out.nil? or out == true)
							out = true
						elsif pkt.raw_data.include? my and (out.nil? or out == true)
							out = true
						else
							out = false
						end
						return m if out
					end
				end
			end
		end
		return nil
	end

	def self.exist? m
		@@mods.include? m
	end

	def self.cmd cmd
		mo = cmd[0]
		mod = "MOD_#{mo}"
		cmd.delete_at(0)
		if eval(mod).respond_to? 'cmd'
			eval(mod).cmd cmd
		end
	end

	def self.job m, pkt
		mod = "MOD_#{m}"
		if eval(mod).respond_to? 'job'
			eval(mod).job pkt
		end
	end

	def self.slug m, string
		mod = "MOD_#{m}"
		if eval(mod).respond_to? 'job'
			return eval(mod).slug string
		end
		return ''
	end

end
