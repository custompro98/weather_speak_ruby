#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'pp'

require 'espeak'

include ESpeak

class Configuration
	@@config = {}

	def self.set(api_key, zip_code)
		@@config["api_key"] = api_key
		@@config["zip_code"] = zip_code
		@@config["format"] = "json"
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

	direction = Hash.new
	direction["N"] = "north"
	direction["NNE"] = "north northeast"
	direction["NE"] = "northeast"
	direction["ENE"] = "east northeast"
	direction["E"] = "east"
	direction["ESE"] = "east southeast"
	direction["SE"] = "southeast"
	direction["SSE"] = "south southeast"
	direction["S"] = "south"
	direction["SSW"] = "south southwest"
	direction["SW"] = "southwest"
	direction["WSW"] = "west southwest"
	direction["W"] = "west"
	direction["WNW"] = "west northwest"
	direction["NW"] = "northwest"
	direction["NNW"] = "north northwest"

	params = Hash.new
	params["key"] = Configuration.get("api_key")
	params["format"] = Configuration.get("format")
	params["q"] = Configuration.get("zip_code")

	uri = base_uri
	params.each_with_index do |(key, val), index|
		if index == 0
			uri += "#{key}=#{val}"
		else
			uri += "&#{key}=#{val}"
		end
	end

	resp = open(uri).read
	result = JSON.parse(resp)

	feels_like = result["data"]["current_condition"][0]["FeelsLikeF"]
	humidity = result["data"]["current_condition"][0]["humidity"]
	desc = result["data"]["current_condition"][0]["weatherDesc"][0]["value"]
	wind_speed = result["data"]["current_condition"][0]["windspeedMiles"]
	wind_dir = direction[result["data"]["current_condition"][0]["winddir16Point"]]

	output = "It feels like #{feels_like} degrees with humidity of #{humidity} percent.  The conditions are #{desc} and wind is traveling at #{wind_speed} miles per hour #{wind_dir}."
	speech = Speech.new(output)
	speech.speak
	# `say #{output}`
end

main

# test = "boop"
# `say #{test}`