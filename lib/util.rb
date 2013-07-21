class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

module Util

	@@ports = Hash.new
	@@allowed = Array.new


	def Util.init
		chars = "abcdefghijklmnopqrstuvwxyz"
		chars = chars + chars.upcase
		chars = chars + "1234567890!.?@#<>()[]{}*'\""
		chars.each_byte do |b|
			@@allowed << b.to_s(16)
		end

	end

	def Util.background bg
  	print "\x1b[48;5;#{bg}m" if bg
	end

	def Util.foreground fg
	  print "\x1b[38;5;#{fg}m" if fg
	end

	def Util._background bg
  	"\x1b[48;5;#{bg}m" if bg
	end

	def Util._foreground fg
	  "\x1b[38;5;#{fg}m" if fg
	end

	def Util.rows
		return `tput lines`.chomp.to_i
	end

	def Util.cols
		return `tput cols`.chomp.to_i
	end

	def Util.numeric?(object)
	  true if Float(object) rescue false
	end

	def Util.str_size str, size
		if str.size < size
			add = ' '*(size.to_i-str.size)
			return "#{str}#{add}"
		else 
			return str.slice(0,size.to_i)
		end
	end

	def Util.time t
		t = (Time.now.to_i-t).to_f
		type = "s"
		if t > 120
			t = t/60
			type = "m"
		end
		if t > 120 and type == "m"
			t = t/60
			type = "h"
		end
		if t > 24 and type == "h"
			t = t/24
			type = "d"
		end
		if type == "s"
			return "#{t.to_i}#{type}"
		else
			return "#{t.to_f.round_to(1)}#{type}"
		end
	end

	def Util.size s
		s = s.to_f
		if s > 2048
			s = s/1024
			type = "kb"
		end
		if s > 1024 and type == "kb"
			s = s/1024
			type = "mb"
		end
		if s > 1024 and type == "mb"
			s = s/1024
			type = "gb"
		end
		if s > 1024 and type == "gb"
			s = s/1024
			type = "tb"
		end
		type = "b" if type.nil?
		return "#{s.to_f.round_to(2)}#{type}"
	end

	def Util.lines num
		num.times do
			print " \n"
		end
	end

	def Util.dump_pkt pkt
		pkt.raw_data.unpack('H*')[0].scan(/../).each_slice(18) do |l|
			print l.join(" ")+" "
			l.each do |x|
				if @@allowed.include? x
					print x.to_i(16).chr
				else
					print "."
				end
			end
			puts ""
		end
	end

	def Util.to_hex pkt
		out = ""
		pkt.raw_data.unpack('H*')[0].scan(/../).each_slice(18) do |l|
			l.each do |x|
				if @@allowed.include? x
					out << x.to_i(16).chr
				else
					out << "."
				end
			end
		end
		out
	end

end


class String
    def is_i?
       !!(self =~ /^[-+]?[0-9]+$/)
    end
end