# encoding: utf-8


class AddReplytoColumn < ActiveRecord::Migration
  def self.change
    add_column :records, :replyto, :limit => 8
  end
end