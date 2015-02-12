require_relative "base"
require "active_record"
require "date"

module RPCHandles
  class Retriever < Auth
    attr_accessor :desc
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("retriever", 0.4, "nidev", "Provide records over XMLRPC")
      puts @desc.digest
    end

    def keyword word
      resQueue = []
      res = Rbitter::Record.where("tweet LIKE (?)", "%#{word}%")
      if not res.nil? and res.length > 0
        resQueue += relations_to_strings(res)
      end
      resQueue
    end

    def retweets
      resQueue = []
      res = Rbitter::Record.where("rt_count > 0")
      if not res.nil? and res.length > 0
        resQueue += relations_to_strings(res)
      end
      resQueue
    end

    def username user
      resQueue = []
      if user.start_with?("@")
        user.gsub!(/@/, "")
      end

      res = Rbitter::Record.where("username = ?", user)
      if not res.nil? and res.length > 0
        resQueue += relations_to_strings(res)
      end
      resQueue
    end

    def within_24h
      res = Rbitter::Record.where(date: (DateTime.now.prev_day..DateTime.now))
      relations_to_strings res
    end

    def within_3days
      res = Rbitter::Record.where(date: (DateTime.now.prev_day(2)..DateTime.now))
      relations_to_strings res
    end

    def between from_DateTime, to_DateTime
      from_DateTime = DateTime.parse(from_DateTime)
      to_DateTime = DateTime.parse(to_DateTime)
      if from_DateTime > to_DateTime
        from_DateTime, to_DateTime = to_DateTime, from_DateTime
      end

      res = Rbitter::Record.where(date: (from_DateTime..to_DateTime))
      relations_to_strings res
    end

    private
    def relative_timestring datetime_obj
      delta = Time.now - datetime_obj.to_time.localtime
      if delta < 60
        "#{delta.round(0)} seconds ago"
      elsif delta < 3600
        "#{(delta/60).round(0)} minutes ago"
      elsif delta < 86400
        "#{(delta/3600).round(0)} hours ago"
      else
        "#{(delta/86400).round(0)} days ago"
      end
    end

    def relations_to_strings rel
      rel.map { |row|
        "@#{row.username} |#{relative_timestring(row.date)}|RT #{row.rt_count} FAV #{row.fav_count}|<br/>#{row.tweet}"
      }
    end
  end
end


