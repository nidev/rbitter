# encoding: utf-8

require "active_record"
require "date"

module Rbitter
  class Record < ActiveRecord::Base
  end
end

module ARSupport
  SCHEME_VERSION = 20150504
  SCHEME = {
    :marker => :integer, # 0 normal, 1 begin 2 halt
    :marker_msg => :string,
    :userid => :integer,
    :username => :string,
    :tweetid => :integer,
    :replyto => :integer,
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
    if Rbitter['activerecord'] == 'sqlite3'
      warn "Warning: If you enable XMLRPC access, using sqlite is not recommended."
      warn "Warning: Random crash can happen because of concurrency."
      
      if RUBY_PLATFORM == 'java'
        require "jdbc/sqlite3"
        Jdbc::SQLite3.load_driver
        ActiveRecord::Base.establish_connection(
          adapter: 'jdbcsqlite3',
          database: Rbitter['sqlite3']['dbfile'],
          timeout: 10000) # Long timeout for slow computer
      else
        ActiveRecord::Base.establish_connection(
          adapter: 'sqlite3',
          database: Rbitter['sqlite3']['dbfile'],
          timeout: 10000) # Long timeout for slow computer
      end
    elsif Rbitter['activerecord'] == 'mysql2'
      Jdbc::MySQL.load_driver if RUBY_PLATFORM == 'java'
      
      ActiveRecord::Base.establish_connection(
        adapter: (RUBY_PLATFORM == 'java' ? 'jdbcmysql' : 'mysql2'),
        host: Rbitter['mysql2']['host'],
        port: Rbitter['mysql2']['port'],
        database: Rbitter['mysql2']['dbname'],
        username: Rbitter['mysql2']['username'],
        password: Rbitter['mysql2']['password'],
        encoding: "utf8mb4",
        collation: "utf8mb4_unicode_ci")
    else
      raise RuntimeException.new("Unknown configuration value. 'activerecord' value should be sqlite3 or mysql2.")
    end
  end

  def disconnect_database
    if ActiveRecord::Base.connected?
      ActiveRecord::Base.connection.close
    end
  end

  def update_database_scheme
    current_version = ActiveRecord::Migrator.current_version
    if current_version < SCHEME_VERSION
      warn "[records] Your ActiveRecord scheme is outdated."
      warn "[records] Migrate... #{current_version} => #{SCHEME_VERSION}"
      ActiveRecord::Migrator.migrate(File.expand_path("../records_migrate", __FILE__), SCHEME_VERSION)
    end
  end

  def prepare option_string=""
    ActiveRecord::Schema.define(version: SCHEME_VERSION) {
      # MySQL specific option_string:
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

      add_index :records, :tweetid
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

  def export_to_csv(csvfile)
    open(csvfile, 'w') { |f|
      f.write("marker,marker_msg,userid,username,tweetid,replyto,tweet,date,rt_count,fav_count")
      f.write("\n")
      Rbitter::Record.find_each { |t|
        f.write("#{t.marker},#{t.marker_msg},#{t.userid},#{t.username},#{t.tweetid},")
        f.write("#{t.replyto},#{t.tweet},#{t.date},#{t.rt_count},#{t.fav_count}\n")
      }
    }
  end
end
