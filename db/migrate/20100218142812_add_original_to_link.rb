class AddOriginalToLink < ActiveRecord::Migration
  def self.up
    add_column :links, :original, :string
  end

  def self.down
    remove_column :links, :original
  end
end
