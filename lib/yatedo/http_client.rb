#encoding: utf-8

##
## http_client.rb
## Gaetan JUVIN 11/08/2015
##

module Yatedo
    USER_AGENTS = ['Windows IE 6', 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox', 'Linux Konqueror']

	def http_client
		Mechanize.new do |agent|
			agent.user_agent_alias = USER_AGENTS.sample
			unless @options.empty?
				agent.set_proxy(@options[:proxy_ip], @options[:proxy_port])
			end
			agent.max_history = 0
		end
	end
end