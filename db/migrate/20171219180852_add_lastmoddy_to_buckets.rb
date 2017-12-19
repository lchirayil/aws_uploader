class AddLastmoddyToBuckets < ActiveRecord::Migration[5.1]
  def change
    add_column :buckets, :last_moddy, :datetime
  end
end
