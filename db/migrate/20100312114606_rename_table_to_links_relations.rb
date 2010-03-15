class RenameTableToLinksRelations < ActiveRecord::Migration
  def self.up
	  drop_table :relations_links
		create_table :links_relations, :id => false  do |t|
		  t.column :link_id, :integer, :null => false
			t.column :relation_id, :integer, :null => false
		end
  end

  def self.down
	  drop_table :links_relations
  end
end
