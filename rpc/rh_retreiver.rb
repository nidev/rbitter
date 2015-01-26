require_relative "base"

module RPCHandles
  attr_accessor :desc

  class Retreiver
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("retreiver", 0.1, "nidev", "Provide records over XMLRPC")
      puts @desc.digest
    end
  end
end

