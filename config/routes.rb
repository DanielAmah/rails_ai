# frozen_string_literal: true

RailsAi::Engine.routes.draw do
  root "dashboard#index"

  resources :streams, only: [:create] do
    member do
      post :stream
    end
  end

  namespace :api do
    namespace :v1 do
      resources :chat, only: [:create]
      resources :embeddings, only: [:create]
      resources :summarize, only: [:create]
    end
  end
end
