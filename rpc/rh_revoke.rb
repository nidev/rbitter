require_relative "base"

module RPCHandles
  attr_accessor :desc

  class RevokeAuthorization
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("revoke", 0.1, "nidev", "Revoke authorization token")
      puts @desc.digest
    end
  end
end

