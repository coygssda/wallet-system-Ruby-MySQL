Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	post '/wallets', to: 'wallets#create'
	get '/wallets/:id', to: 'wallets#show'
	put '/wallets/:id', to: 'wallets#update'
	get '/wallets/:id/history', to: 'wallets#audit'
	delete '/wallets/:id', to: 'wallets#destroy'
	post 'wallets/bulk_update', to: 'wallets#bulk_update'
	post 'wallets/bulk_expiration', to: 'wallets#bulk_expiration'
end
