#!/usr/bin/env ruby
require "thor"
require 'github/markup'
require_relative 'publish.rb'

class DocsCLI < Thor
  desc "sections", "list all sections in Help Center"
  def sections
    hc = ZendeskHc.new(PUBLISH_USERNAME, API_TOKEN)
    sections = hc.sections
    puts "\nList of Sections on Production\n\n"
    puts "Production Site: #{PRODUCTION}\n\n"
    sections.each do |s|
      puts s["id"].to_s+": "+s["name"]
    end
    puts ""
  end

  desc "publish", "Publishes an article in the Help Center, the article is created if doesn't includes an ID in the front matter"
  option :file, :required => true
  def publish
    puts "\nAttempting to publish to Production\nProduction Site: #{PRODUCTION}\n\n"
    hc = ZendeskHc.new(PUBLISH_USERNAME, API_TOKEN)
    section_config_file = File.dirname(options[:file]).concat("/section.yml")
    unless File.exists?(section_config_file)
      puts "Error! Section configuration file not found at #{section_config_file}"
      return 1
    end
    section = YAML.load(File.read(section_config_file))["section_id"]
    response = hc.publish section, options[:file]
    if response.response.is_a?(Net::HTTPCreated) || response.response.is_a?(Net::HTTPOK)
      puts "Article successfully published!\n\n"
    else
      puts response.response
      puts "WARNING! The article was not successfully published."
    end
  end
end

DocsCLI.start(ARGV)
