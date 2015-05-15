# encoding: utf-8


class AddIndex < ActiveRecord::Migration
  def up
    add_index :records, :tweetid
  end

  def change
    up
  end
end