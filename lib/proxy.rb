require 'webrick/httpproxy'

class Proxy

	def handle_request(req, res)
		if @info.has_key? req.host
			req.cookies.clear
			res.cookies.clear
			@info[req.host].split(";").each do |x|
				key = x.split("=")[0].gsub(" ","")
				val = x.split("=")[1].gsub(" ","")
				req.cookies << WEBrick::Cookie.new(key, val)
				res.cookies << WEBrick::Cookie.new(key, val)
			end
		end
	end

	def initialize port, http, filt = nil
		@info = Hash.new

		http.each do |v|
			if filt.nil? or (!v[:cookie].nil? and v[:cookie].include? filt)
				@info[v[:host]] = v[:cookie] if !v[:cookie].nil?
			end
		end

		@port = port

		Thread.new {
			@server = WEBrick::HTTPProxyServer.new(
				:Port => @port,
				:AccessLog => [],
				:ProxyContentHandler => method(:handle_request))
			@server.start
		}

		$mst = :info
		$msg = "Proxy created @ 127.0.0.1:#{port}"
 
	end

	def update http, filt
		@info = Hash.new
		http.each do |v|
			if filt.nil? or (!v[:cookie].nil? and v[:cookie].include? filt)
				@info[v[:host]] = v[:cookie] if !v[:cookie].nil?
			end
		end
	end

	def stop
		@server.shutdown
	end
 
end
