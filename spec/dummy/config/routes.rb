# frozen_string_literal: true

Rails.application.routes.draw do
  resources :projects do
    collection do
      get :deep_new
    end
  end
  root 'projects#index'
end
