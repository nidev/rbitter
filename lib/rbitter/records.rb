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
