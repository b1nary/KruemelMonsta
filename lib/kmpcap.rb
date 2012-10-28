class KMPcap

	def self.init device, pcap_filter

		pcap_filter = 'tcp or udp' if pcap_filter.nil?
		device = self.find_device if device.nil?

		@pcap = Pcaplet.new("-s 25565 -i #{device}")
		# It seems to need a filter ...
		_filter = Pcap::Filter.new(pcap_filter, @pcap.capture)
		@pcap.add_filter(_filter)

		@doit = true
		self.loop
	end

	def self.loop

		Thread.new {
			@pcap.each_packet { |pkt|
				if @doit
					begin
						Data.push pkt
					rescue
					end
				end
			}
		}
	end

	##
	# Start & Stop packet analysing
	def doit val
		@doit = val
	end

	##
	# Find a suitable device
	# Needs some rework
	def self.find_device
		backupdevice = "eth0"
		devices = `ifconfig | grep Link | cut -f1 -d' '`.split("\n").each do |i|
			i.gsub(" ","")
			backupdevice = i
			device = i if i.include? 'eth'
		end
		device = backupdevice if device.nil?
		return device
	end

end
