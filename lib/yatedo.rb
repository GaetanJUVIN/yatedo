require "yatedo/version"
require 'mechanize'
require 'yatedo/http_client'

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
				profiles << Yatedo::Profile.new(profile, options)
			end
			profiles
	    end

	end

	class Profile
		include Yatedo::HttpClient

		attr_accessor :page

		def initialize(nokogiri_object, options)
			@options 	= options
			@page 		= nokogiri_object
			headline 	= @page.search('.vcardtitle')

			agent 		= http_client
			cookie = Mechanize::Cookie.new :domain => '.yatedo.fr', name: 'yatedo[rlg]', value: 'fr', :path => '/', :expires => (Date.today + 1).to_s
			agent.cookie_jar << cookie

			profile_link = if headline.at('a')
				'http://www.yatedo.fr' + headline.at('a')['href']
			else
				headline.at('span')['_ym_href']
			end
			@page  		= agent.get(profile_link)
		end

	    def parse_date(date)
			begin
				return nil if date.strip!.blank?
				date = "#{date}-01-01" if date =~ /^(19|20)\d{2}$/
				Date.parse(date)
			rescue
				nil
			end
	    end

	    def name
	      "#{first_name} #{last_name}"
	    end

	    def first_name
			@first_name ||= @page.at('.p_name_header').text.rpartition(' ').first if @page.at('.p_name_header')
	    end

	    def last_name
			@last_name ||= @page.at('.p_name_header').text.rpartition(' ').last if @page.at('.p_name_header')
	    end

	    def title
			@title ||= @page.at('.p_headline_header').text.strip if @page.at('.p_headline_header')
	    end

	    def location
	    	@location ||= @page.at('.p_location_header').text.rpartition(',').first.strip if @page.at('.p_location_header')
	    end

	    def country
	    	@country ||= @page.at('.p_location_header').text.rpartition(',').last.strip if @page.at('.p_location_header')
	    end

	    def skills
	    	@skills ||= @page.at('#ytdpbox-pskills').search('.row.spanalpha.boxelminline').map(&:text) if @page.at('#ytdpbox-pskills')
	    end

	    def picture
	    end

	    def social_links
	    	return [] if @page.at(".profil_rresult_container") == nil
			@social_links ||= @page.at(".profil_rresult_container").search('.extsh_ctn').map do |row|
				url = row.at('.weblink_url').text
				{name: url.match(/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)/)[2].split('.').last.capitalize, link: url}
			end
	    end

	    def industry
	    end

	    def summary
	    end

	    def groups
	    	[]
	    end

	    def languages
	    	[]
	    end

	    def recommended_visitors
	    	[]
	    end

	    def current_companies
	    	@current_companies	||= get_companies(true)
	    end

	    def past_companies
	    	@past_companies 	||= get_companies(false)
	    end

		def get_companies(current)
			companies = []
			exp_pro    = @page.at('#ytdpbox-pro')
			if exp_pro
				exp_pro.search('.row.spanalpha.boxelm').map do |row|
					company             = {}

					date_begin, date_end = row.search('.newrow/div/span').map(&:text)

					company[:start_date] 	= parse_date(date_begin)
					company[:end_date] 		= parse_date(date_end)

					current_company 		= (company[:start_date] and date_end.blank? == false and company[:end_date] == nil)
					next if current != current_company

					title, company_name	= row.search('.blink/a').map(&:text)
					company[:title] 	= title.strip 		 if title
					company[:company] 	= company_name.strip if company

					company[:description] 	= row.at('.newrow.desc').text.gsub(/\s+|\n/, ' ').strip

					companies << company
				end
			end
			companies
		end

		def education
			educations = []

			noko_educations = @page.at('#ytdpbox-edu')
			if noko_educations
				noko_educations.search('.row.spanalpha.boxelm').map do |row|
					education = {}

					education[:name] 		= row.search('.blink').text

					education[:description] = row.at('.newrow.desc').text.gsub(/\s+|\n/, ' ').strip

					date_begin, date_end = row.at('.newrow/div').text.gsub(/\s+|\n/, ' ').split('-')

					education[:start_date] 	= parse_date(date_begin)
					education[:end_date] 	= parse_date(date_end)

					educations << education
				end
			end
			educations
		end

	end
end
