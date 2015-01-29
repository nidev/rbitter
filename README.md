# Rbitter #

Rbitter is a Twitter streaming client specialized in tweet archiving with remote access via XMLRPC, which is written in Ruby.

You can save all tweets appeared on timeline and watch them later.

## Requirements ##

## System ##

### Twitter Streaming (streaming.rb) ###
###Database (records.rb) ###
### XMLRPC(xmlrpc.rb) ###

## Configuration ##
Default configuration file is provided with the file named 'config.json.example'. Copy it to 'config.json' and edit it.

app.rb and config.json must be in same folder.

## Set up and run ##
### Acquire Twitter Token ###
### Fill up config.json ###
### run ###

## XMLRPC API ##
### What is RPC handle ? ###
### Authentication ###
### Revoke Authentication Token ###
### Echo ###
### Last Active ###
### Retriever ###
### Statistic ###
### How to write own RPC handle? ###
RPC handle is a Ruby class. Writing a method in Ruby class, that's it. Names of methods are treated as XMLRPC command.

When you write a new class for your own RPC handle, you must inherit either Auth or NoAuth class from rpc/base.rb.

* class Auth < Object: Methods in a Ruby class inheriting Auth requires *auth_key* to access.
* class NoAuth < Object: Methods in a Ruby class inheriting NoAuth doesn't require *auth_key* and these XMLRPC commands can be called by anonymous user.

Filename should start with 'rh_'. It's prefix to be autoloaded by xmlrpc.rb.

Refer rpc/rh_echo.rb as an example.

## TODO ##
* XMLRPC
> * Receiving mentions, favorites

## Bugreport or feature request ##
Make a report by clicking 'Issues' on left side menu of Rbitter Bitbucket.

Even though I can read English, Korean and Japanese, I prefer English.

## Disclaimer ##
Rbitter is intended for personal usage. Archived data should not be shared over Internet. Please keep them secure and safe, and protect privacy.

Using sqlite3, please set permission to 0700 so that other users can not read your database file. Using mysql2, please take care of DB access privilege.

Rbitter is not responsible for integrity of data. That is, Some tweets will be dropped accidently due to Twitter API problems or your network problems. The application does its best to recover from those problems. If you find Rbitter couldn't recover even after they're resolved, please make an issue report.



