#encoding: utf-8

##
## search.rb
## Gaetan JUVIN 14/08/2015
##

module Yatedo
	class Search
		include Yatedo::HttpClient

		attr_accessor :page

		def initialize(options)
			@options = options
			url = 'http://www.yatedo.fr/search/profil'

			params = {'q' => "#{options[:first_name]} #{options[:last_name]} #{options[:company]}", 'btn_s' => ''}
			@page  = http_client.get(url, params)
		end

	    def self.get_profiles(options)
			raise Yatedo::MissingArgument.new('first_name') 	unless options[:first_name]
			raise Yatedo::MissingArgument.new('last_name') 		unless options[:last_name]

			yatedo 		= Yatedo::Search.new(options)
			profiles 	= []

			yatedo.page.search('.ycardctn').each do |profile|
				profiles << Yatedo::Profile.new(profile, options)
			end
			profiles
	    end

	end
end