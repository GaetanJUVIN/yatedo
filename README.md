# Yatedo

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/yatedo`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yatedo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yatedo

## Usage

```ruby
profiles = Yatedo::Search.get_profiles(first_name: profile.first_name, last_name: profile.last_name)

profiles.each do |profile|
	profile.first_name
	profile.last_name
	profile.name
	profile.title
	profile.summary
	profile.location
	profile.country
	profile.industry
	profile.picture
	profile.skills
	profile.education
	profile.current_companies
	profile.past_companies
	profile.groups
	profile.languages
	profile.recommended_visitors
	profile.social_links
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

