require "date"
require_relative "base"

module RPCHandles
  attr_accessor :desc

  class LastActiveTime < Auth
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("last_active", 0.1, "nidev", "Tell when the last record is made.")
      puts @desc.digest
    end

    def last_active
      res = Application::Record.last(1)
      if res.length == 1
        res[0].date.to_s
      else
        ""
      end
    end
  end
end

