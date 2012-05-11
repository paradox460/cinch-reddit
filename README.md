This is a simple reddit plugin for the [cinch][1] IRC bot framework

# Commands

+ `!karma <username>`: returns the karma of `<username>`
+ `!readers <subreddit>`: returns the subscriber count of `<subreddit>`
+ `!mods <subreddit>`: returns the mods of `<subreddit>`

# Installing
You need to have the [cinch][1] framework installed, but once you have that done the rest is simple.

 + Write a new bot file, and include `require 'cinch/plugins/reddit'.
 + In your configure block, add `Cinch::Plugins::Reddit`, ex: `c.plugins.plugins = [Cinch::Plugins::Reddit]`

Here is a sample bot:

 ```ruby
require 'cinch'
require 'cinch/plugins/reddit'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.snoonet.com"
    c.nick = "testborg"
    c.channels = [ "#bottest" ]
    c.plugins.plugins = [Cinch::Plugins::Reddit]
  end
end

bot.start
```
