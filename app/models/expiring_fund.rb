class ExpiringFund < ApplicationRecord
	belongs_to :wallet
	audited
end
