#!/usr/bin/env ruby
# Copyright (c) 2012 Jeff Sandberg
# This program is made avalible under the terms of the MIT license.

require 'cinch'
require 'json'
require 'open-uri'
require 'cgi'

module Cinch
  module Plugins
    class Reddit
      include Cinch::Plugin

      RedditBaseUrl = "http://www.reddit.com"
      # Utilities

      # Takes an ingeger, puts commas in appropriate places, and returns a string
      def commify(n)
        n.to_s =~ /([^\.]*)(\..*)?/
        int, dec = $1.reverse, $2 ? $2 : ""
        while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
        end
        int.reverse + dec
      end

      # Loads a URL from the reddit API
      # This saves time, as well as providing our own unique user-agent
      def urlload(url)
        open(url, "User-Agent" => "reddit-irc-bot").read
      end

      # Pluralizes a string
      # Simple and stupid, but it works
      def pluralize(n, singular, plural=nil)
        if n == 1
          "1 #{singular}"
        elsif plural
          "%s %s" % [commify(n), plural]
        else
          "%s %ss" % [commify(n), singular]
        end
      end

      # Plugin code

      # Karma Lookup
      match /karma (\w+)/, method: :karma
      def karma(m, user)
        url = "%s/user/%s/about.json" % [RedditBaseUrl, user]
        data = JSON.parse(urlload url)["data"] rescue nil
        unless data
          m.reply("%s doesn't appear to exist and therefore can't have karma" % user)
        else
          m.reply("%s has a link karma of %s and comment karma of %s" % [ Format(:bold, data["name"]), commify(data["link_karma"]), commify(data["comment_karma"]) ])
        end
      end

      # Subreddit mods
      match /mods (\w+)/, method: :mods
      def mods(m, subreddit)
        url = "%s/r/%s/about/moderators.json" % [RedditBaseUrl, subreddit]
        data = JSON.parse(urlload url)["data"]["children"] rescue nil
        unless data
          m.reply("%s doesn't appear to exist and therefore can't have moderators" % subreddit)
        else
          subMods = []
          data.each { |mod| subMods << mod["name"] }
          m.reply("%s has %s: %s" % [Format(:bold, subreddit), pluralize( subMods.length, "moderator"), subMods[0..-2].join(", ") + ", and " + subMods[-1] ])
        end
      end

      # Subreddit readers
      match /readers (\w+)/, method: :readers
      def readers(m, subreddit)
        url = "%s/r/%s/about.json" % [RedditBaseUrl, subreddit]
        data = JSON.parse(urlload url)["data"]["subscribers"] rescue nil
        unless data
          m.reply("%s doesn't appear to exist and therefore can't have subscribers" % subreddit)
        else
          m.reply("%s has %s" % [Format(:bold, subreddit), pluralize(data, "reader")])
        end
      end
    end
  end
end
