# Rbitter #

Rbitter is a Twitter streaming client specialized in tweet archiving with remote access via XMLRPC, which is written in Ruby.

You can save all tweets appeared on timeline and watch them later.

**Rbitter can be built into a Ruby gem by typing 'gem build rbitter.gemspec'. It is not yet uploaded due to testing.**

## Requirements ##

'bundle update' may install every gem Rbitter needs.

Ruby 2.0.0 or above
Sqlite3
Mysql(MariaDB)

## Configuration ##
You can simply manipulate default configuration file by:

```bash
$ rbitter configure
```

Put your customized config.json to one of below locations.

1. $HOME/config.json
2. $HOME/.rbitter/config.json
3. ./config.json (current folder)
4. ./.rbitter/config.json (current folder)

For location #3 and #4, they're referred when #1 and #2 are not available. In those cases, *rbitter* must be executed from the directory where config.json exists.

## Set up and run ##
1. With config.json,
2. Get Twitter token and copy them properly.
2. Choose preferred ActiveRecord backend.
3. Modify default location where Twitter images are downloaded.
4. Configure XMLRPC server
5. Start by typing:

```bash
$ rbitter serve
```
## XMLRPC API ##

See XMLRPC.md

## TODO ##
* Streaming Client
  * Saving JSON dump
* XMLRPC
  * Receiving direct messages

## Issue report or feature request ##.
It's recommended to open an issue even it seemed too small. A small flaw may result in instability or bad situation. So every feature requests/bug reports are welcomed.

Please attach stack trace, Ruby version, and detail description.

## Disclaimer ##
Rbitter is intended for personal usage. Archived data should not be shared over Internet. Please keep them secure and safe, and protect privacy.

Using sqlite3, please set permission to 0700 so that other users can not read your database file. Using mysql2, please take care of DB access privilege.

Rbitter is not responsible for integrity of data. That is, Some tweets will be dropped accidently due to Twitter API problems or your network problems. The application does its best to recover from those problems. If you find Rbitter couldn't recover even after they're resolved, please make an issue report.
