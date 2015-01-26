# encoding: utf-8

require "active_record"
require "date"

SCHEME = {
  :marker => :integer, # 0 normal, 2 cut, 1 resume
  :marker_msg => :string, # == 0 success, == 2 w/ message
  :userid => :integer,
  :username => :string,
  :tweetid => :integer,
  :tweet => :string, # with url unpacked
  :date => :datetime,
  :rt_count => :integer,
  :fav_count => :integer
}

def init_records_table
  ActiveRecord::Schema.define {
    create_table :records do |t|
      SCHEME.each_key { |column|
        case SCHEME[column]
        when :string
          t.string column
        when :integer
          t.integer column
        when :datetime
          t.datetime column
        else
          puts "Unexpected column type '#{SCHEME[column]}' of #{column}"
        end
      }
    end
  }
end

class Record < ActiveRecord::Base

end

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

