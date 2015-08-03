#!/usr/bin/env ruby
# Copyright (c) 2012 Jeff Sandberg
# This program is made avalible under the terms of the MIT license.

require 'cinch'
require 'json'
require 'open-uri'
require 'cgi'
require 'uri'
require 'action_view'
require 'date'

module Cinch
  module Plugins
    class Reddit
      include Cinch::Plugin
      include ActionView::Helpers::DateHelper

      RedditBaseUrl = "http://www.reddit.com"
      # Utilities

      # Takes an integer, puts commas in appropriate places, and returns a string
      def commify(n)
        /(?<int>[^\.]*)(?<dec>\..*)?/ =~ n.to_s
        int, dec = int.reverse, (dec || "")
        {} while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
        int.reverse + dec
      end

      # Loads a URL from the reddit API
      # This saves time, as well as providing our own unique user-agent
      def urlload(url)
        open(url, "User-Agent" => "reddit-irc-bot", &:read)
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

      # Utility to join an array into a gramarically correct sentence.
      def pluralJoin(array)
        return array[0] unless array.length > 1
        array[0..-2].join(", ") + ", and " + array[-1]
      end

      # Plugin code

      # Karma Lookup
      match /karma (\w+)/, method: :karma
      def karma(m, user)
        url = "%s/user/%s/about.json" % [RedditBaseUrl, user]
        data = JSON.parse(urlload url)["data"] rescue nil
        return m.reply("%s doesn't appear to exist and therefore can't have karma" % user) unless data
        m.reply("%s has a link karma of %s and comment karma of %s" % [ Format(:bold, data["name"]), commify(data["link_karma"]), commify(data["comment_karma"]) ])
      end

      # Subreddit mods
      match /mods (\w+)/, method: :mods
      def mods(m, subreddit)
        url = "%s/r/%s/about/moderators.json" % [RedditBaseUrl, subreddit]
        data = JSON.parse(urlload url)["data"]["children"] rescue nil
        return m.reply("/r/%s doesn't appear to exist and therefore can't have moderators" % subreddit) unless data
        subMods = data.map{ |mod| mod["name"] }
        m.reply("/r/%s has %s: %s" % [Format(:bold, subreddit), pluralize( subMods.length, "moderator"), pluralJoin(subMods) ])
      end

      # Subreddit readers
      match /readers (\w+)/, method: :readers
      def readers(m, subreddit)
        url = "%s/r/%s/about.json" % [RedditBaseUrl, subreddit]
        data = JSON.parse(urlload url)["data"]["subscribers"] rescue nil
        return m.reply("/r/%s doesn't appear to exist and therefore can't have subscribers" % subreddit) unless data
        m.reply("/r/%s has %s" % [Format(:bold, subreddit), pluralize(data, "reader")])
      end

      match /lookup (\S+)/, method: :lookup
      def lookup(m, query)
        url = "%s/api/info.json?url=%s" % [RedditBaseUrl, query]
        data = JSON.parse(urlload url)["data"]["children"][0]["data"] rescue nil
        return m.reply("I couldn't find that for some reason. It might be my fault, or it might be reddit's") unless data
        m.reply("%s - \"%.100s\" %s(%s|%s) by %s, %s ago, to /r/%s" % [
          "http://redd.it/#{data['id']}",
          Format(:bold, data['title']),
          Format(:grey, commify(data['score'])),
          Format(:orange, "+" + commify(data['ups'])),
          Format(:blue, "-" + commify(data['downs'])),
          data['author'],
          time_ago_in_words(DateTime.strptime(data['created'].to_s,'%s')),
          data['subreddit']
          ])
      end

      match /link (\S+)/, method: :linkLookup
      def linkLookup(m, query)
        return unless URI.parse(query).host.end_with?('reddit.com')
        thing_id = URI.parse(query).path.split('/')[4]
        url = "%s/api/info.json?id=t3_%s" % [RedditBaseUrl, thing_id]
        data = JSON.parse(urlload url)["data"]["children"][0]["data"] rescue nil
        return m.reply("I couldn't find that for some reason. It might be my fault, or it might be reddit's") unless data
        m.reply("\"%s\" %s(%s|%s) by %s, %s ago, to /r/%s" % [
          Format(:bold, data['title']),
          Format(:grey, commify(data['score'])),
          Format(:orange, "+" + commify(data['ups'])),
          Format(:blue, "-" + commify(data['downs'])),
          data['author'],
          time_ago_in_words(DateTime.strptime(data['created'].to_s, '%s')),
          data['subreddit']
          ])
      end
    end
  end
end
