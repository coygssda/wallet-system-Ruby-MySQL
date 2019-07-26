class Wallet < ApplicationRecord
	has_many :expiring_funds, dependent: :delete_all
	enum currency: [:usd, :inr, :pound, :euro]
	audited
end
