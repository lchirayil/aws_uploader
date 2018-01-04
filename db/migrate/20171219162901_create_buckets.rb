class CreateBuckets < ActiveRecord::Migration[5.1]
  def change
    create_table :buckets do |t|
      t.string :url
      t.string :filename
      t.timestamps
    end
  end
end
