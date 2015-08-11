require "yatedo/version"

module Yatedo
	class Search
		def initialize(args)
			raise Yatedo::MissingArgument.new('first_name') 	unless args[:first_name]
			raise Yatedo::MissingArgument.new('last_name') 		unless args[:last_name]

			url = 'http://www.yatedo.fr/search/profil'

			params = {'q' 					=> "#{args[:first_name]}+#{args[:last_name]}", 'btn_s' => ''}
			params.merge!('s_fc[s_fc_ac][]' => args[:company])
			response = HTTParty.get(url, query: params)
			p response
		end		
	end

	class Profile

	end
  # Your code goes here...
end
