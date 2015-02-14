require_relative "base"

module RPCHandles
  class Echo < BaseHandle::Auth
    attr_accessor :desc
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("echo", 0.1, "nidev", "Echo Server Plugin")
      puts @desc.digest
    end

    def echo msg
      "ECHO: " + msg
    end
  end
end

