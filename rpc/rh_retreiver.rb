require_relative "base"
require "active_record"

module RPCHandles
  attr_accessor :desc

  class Retreiver < Auth
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("retreiver", 0.1, "nidev", "Provide records over XMLRPC")
      puts @desc.digest
    end

    def include_keyword *words
      resQueue = Array.new
      words.each { |word|
        res = Application::Record.where("tweet LIKE (?)", "%유%")
        reqQueue += relations_to_strings res
      }
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

      res = Application::Record.where(date: (DateTime.now.prev_day(2)..DateTime.now))
      relations_to_strings res
    end

    private
    def relations_to_strings rel
      rel.map { |row|
        "#{row.username}/#{row.date.to_s}\n#{row.tweet}"
      }
    end
  end
end


