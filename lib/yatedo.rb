require "yatedo/version"
require 'mechanize'
require 'http_client'

module Yatedo
	class Search
		include Yatedo::HttpCient

		attr_accessor :page

		def initialize(options)
			@options = options
			url = 'http://www.yatedo.fr/search/profil'

			params = {'q' => "#{options[:first_name]} #{options[:last_name]} #{options[:company]}", 'btn_s' => ''}
			@page  = http_client.get(url, params)
		end

	    def http_client
	      Mechanize.new do |agent|
	        agent.user_agent_alias = USER_AGENTS.sample
	        unless @options.empty?
	          agent.set_proxy(@options[:proxy_ip], @options[:proxy_port])
	        end
	        agent.max_history = 0
	      end
	    end

	    def self.get_profiles(options)
			raise Yatedo::MissingArgument.new('first_name') 	unless options[:first_name]
			raise Yatedo::MissingArgument.new('last_name') 		unless options[:last_name]

			yatedo 		= Yatedo::Search.new(options)
			profiles 	= []

			yatedo.page.search('.ycardctn').each do |profile|
				profiles << Yatedo::Profile.new(profile)
			end
			profiles
	    end

	end

	class Profile
		include Yatedo::HttpCient

		attr_accessor :page

		def initialize(nokogiri_object)
			@page = nokogiri_object
			headline = @page.search('.vcardtitle')
			@page  = http_client.get('http://www.yatedo.fr' + headline.at('a')['href'])
		end
	end
end
