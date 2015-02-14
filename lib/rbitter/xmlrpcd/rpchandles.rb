# encoding: utf-8

module RPCHandles
  # Override this function will activate authentication feature.
  # You can write and add RPCHandle. See 'rpc' folder.

  @@auth_pool = nil
  module_function
  def auth
    @@auth_pool
  end
end