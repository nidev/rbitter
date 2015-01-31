require_relative "base"
require "active_record"

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
      res = Application::Record.where("tweet LIKE (?)", "%#{word}%")
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

      res = Application::Record.where("username = ?", user)
      if not res.nil? and res.length > 0
        resQueue += relations_to_strings(res)
      end
      resQueue
    end

    def within_24h
      res = Application::Record.where(date: (DateTime.now.prev_day..DateTime.now))
      relations_to_strings res
    end

    def within_3days
      res = Application::Record.where(date: (DateTime.now.prev_day(2)..DateTime.now))
      relations_to_strings res
    end

    def between from_DateTime, to_DateTime
      from_DateTime = DateTime.parse(from_DateTime)
      to_DateTime = DateTime.parse(to_DateTime)
      if from_DateTime > to_DateTime
        from_DateTime, to_DateTime = to_DateTime, from_DateTime
      end

      res = Application::Record.where(date: (from_DateTime..to_DateTime))
      relations_to_strings res
    end

    private
    def relations_to_strings rel
      # TODO: Try to serve ORM as-is. Converting to localtime should be done at client side.
      rel.map { |row|
        "@#{row.username}/#{row.date.to_time.localtime.to_s}<br/>#{row.tweet}"
      }
    end
  end
end


