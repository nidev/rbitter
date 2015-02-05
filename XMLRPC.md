# What is RPC handle ? #
## Commands ##
### Authentication ###
### Revoke Authentication Token ###
### Echo ###
### Last Active ###
### Retriever ###
### Statistic ###
# How to write own RPC handle? #
RPC handle is a Ruby class. Writing a method in Ruby class, that's it. Names of methods are treated as XMLRPC command.

When you write a new class for your own RPC handle, you must inherit either Auth or NoAuth class from rpc/base.rb.

* class Auth < Object: Methods in a Ruby class inheriting Auth requires *auth_key* to access.
* class NoAuth < Object: Methods in a Ruby class inheriting NoAuth doesn't require *auth_key* and these XMLRPC commands can be called by anonymous user.

Filename should start with 'rh_'. It's prefix to be autoloaded by xmlrpc.rb.

Refer rpc/rh_echo.rb as an example.
