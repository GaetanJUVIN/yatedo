#encoding: utf-8

##
## exception.rb
## Gaetan JUVIN 11/08/2015
##

module Yatedo
  class MissingArgument < StandardError
  	attr_reader :argument

	def initialize(arg)
		@arg = arg
	end
  end
end
