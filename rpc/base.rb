RH_INFO = Struct.new("RPCHANDLE_INFO", :name, :version, :author, :description) {
  def digest
    "<rpchandle: #{name}-#{version} (written by #{author}, #{description})>"
  end
}


