class WalletsController < ApplicationController
	before_action :authenticate
	rescue_from ActiveRecord::RecordNotFound do |_e|
		render json: { message: "WALLET NOT FOUND !"}
	end
	# create a wallet
	def create
		wallet = Wallet.create(currency: params['currency'],
							   user_name: params['user_name'],
							   pan: params['pan'])
		render json: wallet.attributes
	end

	# display wallet details
	def show
		wallet = Wallet.find(params['id'])
		w_attr =  wallet.attributes
		balance = w_attr['balance']
		w_attr['expiring_funds'] = wallet.expiring_funds.where(debited: false).collect do |expiring_funds|
			balance += expiring_funds.fund
			expiring_funds.attributes
		end
		w_attr['balance'] = balance
		render json: w_attr
	end

	# add/remove funds from wallets
	def update
		wallet = Wallet.find(params['id'])
		if params['operation'] == 'add_funds'
			if (params['days_to_expiry'].to_i > 0)
				ExpiringFund.create(wallet_id: wallet.id, fund: params['fund'],
									expiry_date: (DateTime.now + params['days_to_expiry']))
			else
				wallet.update_attributes(balance: (wallet.balance + params['fund']))
			end
		else
			funds_to_remove = params['fund']
			if funds_to_remove > wallet.balance
				funds_to_remove = funds_to_remove - wallet.balance
				wallet.update_attributes(balance: 0)
				expiring_funds = wallet.expiring_funds
				expiring_funds.each do |expiring_fund|
					if funds_to_remove > expiring_fund.fund
						funds_to_remove = funds_to_remove - expiring_fund.fund
						expiring_fund.update_attributes(fund: 0, debited: true)
					else
						expiring_fund.update_attributes(fund:  expiring_fund.fund - funds_to_remove)
						funds_to_remove = 0
						break;
					end
				end	
			else
				wallet.update_attributes(balance: (wallet.balance - funds_to_remove))
			end
		end
		w_attr =  wallet.attributes
		w_attr['expiring_funds'] = wallet.expiring_funds.collect do |expiring_funds|
			expiring_funds.attributes
		end
		render json: w_attr
	end

	# returns history for a particular wallet
	def audit
		wallet = Wallet.find(params['id'])
		w_attr =  wallet.attributes
		audits = wallet.audits
		w_attr['audits'] = audits.collect do |audit|
			audit.attributes
		end
		render json: w_attr
	end

	# adds funds for each wallet
	def bulk_update
		wallet_details = {}
		params['data'].each do |datum|
			wallet_details[datum["wallet_id"].to_i] = { days_to_expiry: datum["days_to_expiry"], fund: datum["fund"] }
		end
		wallet_ids = wallet_details.keys
		wallets = Wallet.where(id: wallet_ids)
		w_attr = {}
		wallets.each do |wallet|
			details = wallet_details[wallet.id]
			if details[:days_to_expiry].to_i > 0
				ExpiringFund.create(wallet_id: wallet.id, fund: details[:fund],
									expiry_date: (DateTime.now + details[:days_to_expiry]))
			else
				wallet.update_attributes(balance: (wallet.balance + details[:fund].to_i))
			end
			w_attr[wallet.id] =  wallet.attributes
			w_attr[wallet.id]['expiring_funds'] = wallet.expiring_funds.collect do |expiring_funds|
				expiring_funds.attributes
			end
		end
		render json: w_attr
	end

	# expires all funds for that particular date_time
	def bulk_expiration
		ExpiringFund.where("expiry_date < DATE(?)", DateTime.now+2).update_all(debited: true)
		render json: { message: "EXPIRED SUCCESSFULLY !"}
	end

	# delete a wallet
	def destroy
		wallet = Wallet.find_by(id: params['id'])
		if wallet.nil?
			render json: { message: "WALLET NOT FOUND !"}
		else
			wallet.destroy 
			render json: { message: "WALLET DELETED" }
		end
	end

	private

	def authenticate
		render json: { auth: "INVALID TOKEN !" } if request.headers['token'] != "MY_PASS"
	end
end
