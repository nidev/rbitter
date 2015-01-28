require_relative "base"

module RPCHandles
  attr_accessor :desc

  class Authorization < NoAuth
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("auth", 0.1, "nidev", "Rbitter XMLRPC authorization plugin")
      puts @desc.digest
    end
  end
end

