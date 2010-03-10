#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
# gem 'highline', "1.2.9"

require 'highline'
require 'base64'
require 'yaml'


module AccountManager
  class Account
    attr_accessor       :user, :password, :since_id

    @user       = ""
    @password   = ""
    @since_id   = ""
    @yml_file   = nil

    #--------------------------------------------------
    def initialize(yml_file)
      @yml_file = yml_file

      # immediately return when file does not exist.
      if !exist?
        return
      end

      # open yaml file.
      yml = YAML.load_file(@yml_file)

      # immediately return when cannot open the file.
      if ! yml
        return
      end

      # retrieve information from the yaml file.
      ## username
      if defined? yml['user']
        @user = yml['user']
      end
      ## encoded password
      if defined? yml['pass']
        @password = Base64.decode64(yml['pass'])
      end
      ## last processed ID
      if defined? yml['since_id']
        @since_id = yml['since_id']
      end
    end

    #--------------------------------------------------
    def interactive_input
      print "Please enter your id and password.\n"
      user = HighLine.new.ask('ID: ')
      pass = HighLine.new.ask('Password: ') {|q| q.echo = '*' }
      since_id = HighLine.new.ask('Since ID: ')

      if !valid?(user, pass, since_id)
        print "Invalid id or password.\n"
        return false
      end

      @user     = user
      @password = pass
      @since_id = since_id
    end

    #--------------------------------------------------
    def update
      if !valid?
        return false
      end

      enc_pass = Base64.encode64(@password)

      yml = File.open(@yml_file, 'w')
      begin
        yml.puts "user: #{@user}"
        yml.puts "pass: #{enc_pass}"
        if ! (@since_id == nil || @since_id == "")
          yml.puts "since_id: #{@since_id}"
        end
      ensure
        yml.close
      end
    end

    #--------------------------------------------------
    def valid?(user=@user, pass=@password, since_id=@since_id)
      # user and pass are mandatory.
      if (user == "" || pass == "")
        return false
      end

      return true
    end

    #--------------------------------------------------
    def exist?
      # return false when no file exists.
      if !FileTest.exist?(@yml_file)
        return false
      end
      # path is available, but not a file.
      if !FileTest::file?(@yml_file)
        return false
      end
      return true
    end

  end # end of class
end # end of module
