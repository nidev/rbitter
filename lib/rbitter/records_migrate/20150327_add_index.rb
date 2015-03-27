# encoding: utf-8


class AddIndex < ActiveRecord::Migration
  def self.change
    add_index :records, :tweetid
  end
end