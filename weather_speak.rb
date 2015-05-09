#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'pp'

class Configuration
	@@config = {}

	def self.set(api_key, zip_code)
		@@config["api_key"] = api_key
		@@config["zip_code"] = zip_code
	end

	def self.get(property_name)
		@@config[property_name]
	end
end

def init
	config_path = ENV["HOME"] + "/.weatherspeak"
	if File.exist?(config_path)
		f = File.open(config_path, "r")
		api_key = f.gets
		zip_code = ARGV[0]
		if zip_code.nil?
			zip_code = f.gets
		end
		f.close
	else
		puts "worldweatheronline API key: "
		api_key = STDIN.gets
		zip_code = ARGV[0]
		if zip_code.nil?
			zip_code = "48067"
		end

		f = File.open(config_path, "w")
		f.puts api_key
		f.puts zip_code
		f.close
	end

	Configuration.set(api_key.rstrip, zip_code.rstrip)
end

def main
	init
	base_uri = 'http://api.worldweatheronline.com/free/v2/weather.ashx?'

	params = Hash.new
	params["key"] = Configuration.get("api_key")
	params["q"] = Configuration.get("zip_code")

	uri = base_uri
	params.each_with_index do |(key, val), index|
		if index == 0
			uri += "#{key}=#{val}"
		else
			uri += "&#{key}=#{val}"
		end
	end

	puts uri
end

main

# if test.nil?
# 	puts "It was nil!"
# else
# 	puts test
# end

# resp = open(url).read

# result = JSON.parse(resp)
# puts result
# test = "boop"
# `say #{test}`