class CreateExpiringFunds < ActiveRecord::Migration[5.2]
  def change
    create_table :expiring_funds do |t|
      t.boolean :debited, default: false, null: false
      t.datetime :expiry_date
      t.integer :fund, default: 0, null: false
      t.integer :wallet_id
      t.timestamps
    end
  end
end
