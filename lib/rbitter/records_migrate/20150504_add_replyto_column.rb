# encoding: utf-8


class AddReplytoColumn < ActiveRecord::Migration
  def self.up
    add_column :records, :replyto, :limit => 8
  end

  def self.change
    self.up
  end
end