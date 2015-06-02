# encoding: utf-8
require 'socket'

class Socket
  def self.ip_address_list
    fail NotImplementedError
  end
end
