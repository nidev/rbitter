require_relative "base"

module RPCHandles
  attr_accessor :desc

  class LastActiveTime
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("last_active", 0.1, "nidev", "Tell when the last record is made.")
      puts @desc.digest
    end
  end
end

