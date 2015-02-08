RH_INFO = Struct.new("RPCHANDLE_INFO", :name, :version, :author, :description) {
  def digest
    "<rpchandle: #{name}-#{version} (written by #{author}, #{description})>"
  end
}

# If a handler doesn't require an authorization, please inherit below class
class NoAuth < Object
  def auth?
    false
  end
end

# If a handler does require an authorization, please inherit below class
class Auth < Object
  def auth?
    true
  end
end


