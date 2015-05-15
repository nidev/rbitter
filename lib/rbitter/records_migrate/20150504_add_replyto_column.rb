# encoding: utf-8


class AddReplytoColumn < ActiveRecord::Migration
  def up
    add_column :records, :replyto, :integer, :limit => 8
  end

  def change
    up
  end
end