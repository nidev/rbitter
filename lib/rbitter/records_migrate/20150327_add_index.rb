# encoding: utf-8


class AddIndex < ActiveRecord::Migration
  def self.up
    add_index :records, :tweetid
  end

  def self.change
    self.up
  end
end