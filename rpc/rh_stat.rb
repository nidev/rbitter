require_relative "base"

module RPCHandles
  attr_accessor :desc

  class Statistics
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("stat", 0.1, "nidev", "Rbitter stat provider")
      puts @desc.digest
    end
  end
end

