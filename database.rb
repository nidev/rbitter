# encoding: utf-8

begin
  require "mysql2"
rescue => error
  puts "Mysql2 is required to initiate backend."
  exit -1
end

require "date"

DEFAULT_CONF = {
  :host => "localhost",
  :port => "3306",
  :dbname => "core",
}

SCHEME = {
  :id => :INT, # shit...
  :marker => :TINYINT, # 0 normal, 2 cut, 1 resume
  :marker_msg => :TEXT, # == 0 success, == 2 w/ message
  :userid => :BIGINT,
  :username => :TEXT,
  :tweetid => :BIGINT,
  :tweet => :TEXT, # with url unpacked
  :date => :DATETIME,
  :rt_count => :INT,
  :fav_count => :INT,
}

module Database
  def self.to_csv(hash_object)
  end


  class DBHandler
    def initialize(**db_conf)
      @host = db_conf[:host].nil? ? DEFAULT_CONF[:host] : db_conf[:host]
      @port = db_conf[:port].nil? ? DEFAULT_CONF[:port] : db_conf[:port]
      @dbname = db_conf[:dbname].nil? ? DEFAULT_CONF[:dbname] : db_conf[:dbname]
      @sql = nil
    end

    def link(username, password)
      begin
        @sql = Mysql2::Client.new(:username => username, :password => password)
        @sql.select_db(@dbname)
      rescue Mysql2::Error => e
        puts "Mysql2 was not able to connect. (#{e.to_s})"
      end
    end

    def unlink
      puts "Bye"
    end

    def insert_into(table, **valhash)
      # XXX: Doesn't check existence of a table
      col_names = SCHEME.keys.join(", ")
      query = ["INSERT INTO `#{table}` (#{col_names}) VALUES "]
      query.push("(")
      SCHEME.keys.each { |col_name|
        if valhash.include?(col_name)
          case valhash[col_name]
          when String
            if SCHEME[col_name] == :TEXT
              # SQL Injection prevention
              query.push("\"#{@sql.escape(valhash[col_name])}\"")
            else
              query.push("\"#{valhash[col_name]}\"")
            end
          when Time
            query.push("\"#{any_to_datetime(valhash[col_name])}\"")
          when DateTime
            query.push("\"#{any_to_datetime(valhash[col_name])}\"")
          when NilClass
            query.push("null")
          else
            query.push("#{valhash[col_name]}")
          end
        else
          query.push("null")
        end
        query.push(",")
      }
      query.pop
      query.push(");")
      #puts query.join(" ")
      res = @sql.query(query.join(" "))

    end

    def pick_all(table)
      res = @sql.query("SELECT * FROM `#{table}`")
      if res.none?
        nil
      else
        res.entries
      end
    end

    def pick_between_time(table, from_datetime, to_datetime)
      fd, td = any_to_datetime(from_datetime), any_to_datetime(to_datetime)
      res = @sql.query("SELECT * FROM `#{table}` BETWEEN ")
    end

    def pick_regex(table, regex)
      r = pick_all
      r.keep_if { |each_item| 
        each_item['tweet'].match
      }
      pick_all
    end


    def create_if_not_exists(table_name, key_column='id')
      @sql.query(generate_create_table(table_name))
      begin
        @sql.query("ALTER TABLE `#{table_name}` MODIFY COLUMN `#{key_column}` INT PRIMARY KEY AUTO_INCREMENT")
      rescue Mysql2::Error => e
        # it's okay.
        ;
      end
    end

    private
    def any_to_datetime(obj)
      if obj.is_a?(String)
        # try to parse it
        DateTime.parse(obj).strftime("%Y-%m-%d %H:%M:%S")
      elsif obj.is_a?(DateTime) or obj.is_a?(Time)
        obj.strftime("%Y-%m-%d %H:%M:%S")
      else
        raise ArgumentError.new("Can\'t automatically extract DateTime info")
      end
    end

    def generate_create_table(table_name)
      query = ["CREATE TABLE IF NOT EXISTS `#{table_name}`"]
      query.push("(")
      SCHEME.to_a.each { |col|
        query.push("#{col[0].to_s} #{col[1].to_s.upcase}")
        query.push(",")
      }
      query.pop
      query.push(");")
      query.join(" ")
    end
  end
end