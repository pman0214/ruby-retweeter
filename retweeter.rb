#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'twitter'

require File.join(File.dirname(__FILE__), 'account')


# retrieve account information.
account = AccountManager::Account.new("#{ENV['HOME']}/.retweeter")

# when no information available, ask a user to input information.
if ! account.user
  account.interactive_input
  account.update
end


# authentication
httpauth = Twitter::HTTPAuth.new(account.user, account.password, {:ssl => true})
base = Twitter::Base.new(httpauth)
# connetct to twitter
client = Twitter::Base.new(base)

# retrieve direct messages
if ! (account.since_id == nil || account.since_id == "")
  tweets = client.direct_messages({:since_id => "#{account.since_id}"})
else
  tweets = client.direct_messages
end

# retrieve friends list
friends = client.friend_ids

if tweets != nil
  tweets.reverse_each {|tweet|
    # retweet direct messages from friends
    if friends.include?(tweet.sender_id)
#       ### debug begin
#       print "------------------------------\n"
#       print "ID  : #{tweet.id}\n"
#       print "From: #{tweet.sender_screen_name}\n"
#       print "Text: #{tweet.text}\n"
#       ### debug end

      text = "#{tweet.sender_screen_name}: #{tweet.text}"
#       ### debug begin
#       print "#{text}\n"
#       ### debug end
      client.update(text)

      account.since_id = "#{tweet.id}"
    end
  }
end

# update since_id
account.update
