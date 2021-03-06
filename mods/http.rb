class MOD_http

	@@http = Array.new
	@@filter = nil
	@@proxy = nil
	@@helptext = ["HTTP Modul","Usage: http command [parameter]","","Commands:"," list\t\t\tlist captured requests"," size\t\t\trequest count"," filter FILTER\t\tset filter"," filter clear\t\tclear filter"," remove VALUE\t\tremove by value","","Full Info:"," NUM\t\tjust type the request id as command","","Cookie Proxy","Spawn Proxy session for specific requests with:"," proxy PORT [FILTER]\t","Yes you can filter the session per cookie content, you need also:"," proxy stop\t"," proxy update [FILTER]\t"]

	def self.strings
		[['HTTP/','Content-Length:'],['GET /','ost: '],['POST /','ost: ']]
	end

	def self.slug d
		if d.raw_data.include? 'Host: '
			return "[HTTP] "+d.raw_data.split("Host: ")[1].split("\n")[0].chomp()
		end
		return ''
	end

	def self.job pkt
		if pkt.raw_data.include? 'GET /' or pkt.raw_data.include? 'POST /'
			data = pkt.raw_data.split("\r\n\r\n")[0]
			pkg = Hash.new
			pkg[:host] = data.downcase.split("host: ")[1].split("\r\n")[0] if data.downcase.include? 'host: '
			pkg[:host] = "???" if pkg[:host].nil?
			pkg[:agent] = data.split("gent: ",2)[1].split("\r\n")[0] if data.downcase.include? 'user-agent: '
			(pkg[:request] = data.split("GET ",2)[1].split(" HTTP/")[0]; pkg[:method] = "GET") if data.include? 'GET '
			(pkg[:request] = data.split("POST ",2)[1].split(" HTTP/")[0]; pkg[:method] = "POST") if data.include? 'POST '
			pkg[:cookie] = data.split("ookie: ")[1].split("\r\n")[0] if data.downcase.include? 'cookie: '
			pkg[:referer] = data.split("eferer: ")[1].split("\r\n")[0] if data.downcase.include? 'referer: '
			@@http << pkg
		end

	end

  def self.numeric? i
    Float(i) != nil rescue false
  end

	def self.cmd cmd
		if cmd[0] == "size"
			puts "\n\n You have #{@@http.length} captured Requests"

		elsif cmd[0] == "list" or cmd[0] == ""
			if !@@filter.nil?
				$mst = :info
				$msg = "Filter on: #{@@filter}"
			end
			Cli.list_http @@http, @@filter

		elsif cmd[0] == "filter"
			if cmd[1] == "clear"
				@@filter = nil
				$mst = :info
				$msg = "Filter cleared"
			else
				filt = cmd.join(" ").gsub("filter ",'')
				@@filter = filt
				$mst = :info
				$msg = "Filter set to \"#{filt}\""
			end
			Cli.list_http @@http, @@filter

		elsif cmd[0] == "remove"
			value = cmd.join(" ").gsub('remove ','')
			@@http.each_with_index do |l,i|
				@@http.delete_at(i) if (l[:host].include?(value) or l[:request].include?(value) or l[:method].include?(value) or (!l[:cookie].nil? and l[:cookie].include?(value)) or (!l[:referer].nil? and l[:referer].include?(value)))
			end
			Cli.list_http @@http, @@filter

		elsif cmd[0] == "proxy" and !cmd[1].nil?
			if  cmd[1] == "stop"
				if !@@proxy.nil?
					@@proxy.stop
					@@proxy = nil
					$mst = :info
					$msg = "Proxy stopped"
				else
					@@proxy = nil
					$mst = :error
					$msg = "No Proxy running"
				end
			elsif cmd[1] == "update"
				if !@@proxy.nil?
					filt = cmd[2] if !cmd[2].nil?
					@@proxy.update @@http, filt
					$mst = :info
					$msg = "Proxy's Cookie DB updated"
				else
					$mst = :error
					$msg = "No Proxy running"
				end

			else
				if @@proxy == nil
					if cmd[1].is_i?
						port = cmd[1]
						filt = nil
						filt = cmd[2] if !cmd[2].nil?
						@@proxy = Proxy.new(port,@@http,filt)
					else
						$mst = :error
						$msg = "Not a valid port"
					end
				else
					$mst = :error
					$msg = "There is already a proxy running"
				end
			end

		elsif self.numeric?(cmd[0])
			Cli.list_2col "Package info:", @@http[cmd[0].to_i] if !@@http[cmd[0].to_i].nil?

		else
			Cli.help @@helptext

		end
	end

end

