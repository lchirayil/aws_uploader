class AddColumnsToBucket < ActiveRecord::Migration[5.1]
  def change
    add_column :buckets, :key, :string
    add_column :buckets, :last_mod, :string 
  end
end
