# encoding: utf-8

require "active_record"
require "date"

module Rbitter
  class Record < ActiveRecord::Base
  end
end

module ARSupport
  SCHEME = {
    :marker => :integer, # 0 normal, 2 cut, 1 resume
    :marker_msg => :string, # == 0 success, == 2 w/ message
    :userid => :integer,
    :username => :string,
    :tweetid => :integer,
    :tweet => :text, # with url unpacked
    :date => :datetime,
    :rt_count => :integer,
    :fav_count => :integer
  }

  module_function
  def prepared?
    ActiveRecord::Base.connection.table_exists?(:records)
  end

  def connect_database
    if Rbitter.env['activerecord'] == 'sqlite3'
      puts "Warning: If you enable XMLRPC access, using sqlite is not recommended."
      puts "Warning: Random crash can happen because of concurrency."
      
      if RUBY_PLATFORM == 'java'
        require "jdbc/sqlite3"
        Jdbc::SQLite3.load_driver
        ActiveRecord::Base.establish_connection(
          adapter: 'jdbcsqlite3',
          database: Rbitter.env['sqlite3']['dbfile'],
          timeout: 10000) # Long timeout for slow computer
      else
        ActiveRecord::Base.establish_connection(
          adapter: 'sqlite3',
          database: Rbitter.env['sqlite3']['dbfile'],
          timeout: 10000) # Long timeout for slow computer
      end
    elsif Rbitter.env['activerecord'] == 'mysql2'
      Jdbc::MySQL.load_driver if RUBY_PLATFORM == 'java'
      
      ActiveRecord::Base.establish_connection(
        adapter: (RUBY_PLATFORM == 'java' ? 'jdbcmysql' : 'mysql2'),
        host: Rbitter.env['mysql2']['host'],
        port: Rbitter.env['mysql2']['port'],
        database: Rbitter.env['mysql2']['dbname'],
        username: Rbitter.env['mysql2']['username'],
        password: Rbitter.env['mysql2']['password'],
        encoding: "utf8mb4",
        collation: "utf8mb4_unicode_ci")
    else
      raise RuntimeException.new("Unknown configuration value. 'activerecord' value should be sqlite3 or mysql2.")
    end
  end

  def migrate_version new_version
    # STUB
  end

  def prepare option_string=""
    # SCHEME is defined at records.rb
    ActiveRecord::Schema.define(version: 20150202) {
      # utf8mb4 -> supporting UTF-8 4-byte characters (i.e. Emoji)
      create_table(:records, { :options => option_string }) do |t|
        SCHEME.each_key { |column|
          case SCHEME[column]
          when :string
            t.string column
          when :integer
            t.integer column, :limit => 8
          when :datetime
            t.datetime column
          when :text
            t.text column
          else
            puts "Unexpected column type '#{SCHEME[column]}' of #{column}"
          end
        }
      end

      #add_index :records, :tweetid, unique: true
    }
  end

  def any_to_datestring(obj)
    if obj.is_a?(String)
      # try to parse it
      DateTime.parse(obj).strftime("%Y-%m-%d %H:%M:%S")
    elsif obj.is_a?(DateTime) or obj.is_a?(Time)
      obj.strftime("%Y-%m-%d %H:%M:%S")
    else
      raise ArgumentError.new("Can\'t automatically extract DateTime info")
    end
  end
end
