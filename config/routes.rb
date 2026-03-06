# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "sessions#new"

  resource :session, only: %i[new create destroy]
  get "sign_up", to: "users#new", as: :sign_up

  get "share", to: "expenses#new", as: :share_expense
  resources :expenses, only: %i[create show]

  get "dashboard", to: "dashboard#index", as: :dashboard

  resources :users, only: %i[index new create show]
end
