# encoding: utf-8

require "active_record"
require "date"

module Application
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

  class Record < ActiveRecord::Base

  end

  module_function
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
end
