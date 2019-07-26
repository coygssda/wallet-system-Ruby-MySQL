class CreateWallets < ActiveRecord::Migration[5.2]
  def change
    create_table :wallets do |t|
	  t.string :user_name
	  t.string :pan
      t.integer :currency, default: 1, null: false
      t.integer :balance, default: 0, null: false
      t.timestamps
    end
  end
end
