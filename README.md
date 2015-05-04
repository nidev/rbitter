# Rbitter #
[![Build Status](https://travis-ci.org/nidev/rbitter.svg?branch=master)](https://travis-ci.org/nidev/rbitter)
[![Gem Version](https://badge.fury.io/rb/rbitter.svg)](http://badge.fury.io/rb/rbitter)
[![Coverage Status](https://coveralls.io/repos/nidev/rbitter/badge.svg?branch=master)](https://coveralls.io/r/nidev/rbitter?branch=master)

Rbitter is a Twitter streaming client specialized in tweet archiving with remote access via XMLRPC, which is written in Ruby.

You can save all tweets appeared on your home timeline and watch them later.

## Requirements ##

Gem dependencies will be installed during installation of this gem.

* Ruby 1.9.3 or above
* Sqlite3
* Mysql(MariaDB)

## Configuration ##
You can simply manipulate default configuration file by:

```bash
$ rbitter configure
```

Put your customized config.json to one of below locations.

1. ./config.json (current folder)
2. ./.rbitter/config.json (current folder)

## Set up and run ##
With config.json,

1. Get Twitter token and copy them properly.
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

## Issue report or feature request ##
It's recommended to open an issue even it seemed too small. A small flaw may result in instability or bad situation. So every feature requests/bug reports are welcomed.

Please attach stack trace, Ruby version, Rbitter version, and detail description.

If you installed from [RubyGems], please report with Git tag. Git tag is your gem version.

[RubyGems]: https://rubygems.org

## Disclaimer ##
Rbitter is intended for personal usage. Archived data should not be shared over Internet. Please keep them secure and safe, and protect privacy.

Using sqlite3, please set permission to 0700 so that other users can not read your database file. Using mysql2, please take care of DB access privilege.

Rbitter is not responsible for integrity of data. That is, Some tweets will be dropped accidently due to Twitter API problems or your network problems. The application does its best to recover from those problems. If you find Rbitter couldn't recover even after they're resolved, please make an issue report.
