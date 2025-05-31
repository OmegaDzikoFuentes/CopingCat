# config/routes.rb
Rails.application.routes.draw do
  devise_for :users, controllers: {
  registrations: 'registrations'
}
  get "social/Controller"
  get "game/Controller"
  # Devise routes for user authentication
  
  
  # Root route
  root 'analytics#dashboard'

  
  
  # Main application routes
  resources :emotions do
    member do
      get :statistics
    end
  end
  
  resources :triggers do
    member do
      get :patterns
      get :statistics
    end
  end
  
  resources :contexts
  
  resources :coping_strategies do
    member do
      post :use # For quick use during episodes
    end
  end
  
  resources :diary_entries do
    collection do
      get :search
    end
  end
  
  resources :emotional_episodes do
    # Nested routes for related resources
    resources :physical_symptoms do
      collection do
        post :quick_add
      end
    end
    
    resources :behavior_reactions
    
    # Custom episode routes
    collection do
      get :quick_log
      post :create_quick
    end
    
    member do
      patch :end_episode
      get :timeline
    end
  end
  
  resources :user_goals do
    member do
      patch :complete
      patch :pause
      patch :resume
    end
  end
  
  resources :prediction_feedbacks do
    collection do
      post :quick_feedback
    end
  end
  
  # Cat-related routes
  resources :cats do
    collection do
      get :random
    end
  end
  
  resources :user_cat_customizations, path: 'my_cat' do
    collection do
      get :customize
      post :save_customization
      get :preview
    end
    
    member do
      post :reset_to_default
      patch :update_colors
      patch :update_accessories
    end
  end
  
  # Analytics and reporting routes
  get 'analytics', to: 'analytics#dashboard'
  get '/analytics/dashboard', to: 'analytics#dashboard', as: 'analytics_dashboard'
  get 'analytics/emotions', to: 'analytics#emotions'
  get 'analytics/triggers', to: 'analytics#triggers'
  get 'analytics/patterns', to: 'analytics#patterns'
  get 'analytics/export', to: 'analytics#export'
  
  # API routes
  namespace :api do
    namespace :v1 do
      # API authentication and user info
      post 'auth/login', to: 'authentication#login'
      post 'auth/logout', to: 'authentication#logout'
      get 'auth/me', to: 'authentication#me'
      
      # Core API endpoints
      resources :emotional_episodes, only: [:index, :show, :create, :update] do
        resources :physical_symptoms, only: [:create, :destroy]
        
        member do
          patch :end_episode
        end
      end
      
      resources :emotions, only: [:index, :show]
      resources :triggers, only: [:index, :show]
      resources :coping_strategies, only: [:index, :show, :create]
      
      # Quick logging endpoint
      post 'quick_log', to: 'quick_log#create'
      
      # User preferences and settings
      get 'user/profile', to: 'users#profile'
      patch 'user/profile', to: 'users#update_profile'
      
      # Analytics endpoints
      get 'analytics/summary', to: 'analytics#summary'
      get 'analytics/trends', to: 'analytics#trends'
      get 'analytics/insights', to: 'analytics#insights'
      
      # Cat API endpoints
      resources :cats, only: [:index, :show]
      resources :user_cat_customizations, path: 'my_cat', only: [:show, :update] do
        collection do
          post :randomize
        end
      end
    end
  end
  
  # Health check and system routes
  get 'health', to: 'application#health_check'
  
  # Admin routes (if you have admin functionality)
  namespace :admin do
    resources :users, only: [:index, :show, :edit, :update] do
      member do
        patch :suspend
        patch :unsuspend
      end
    end
    
    resources :emotions
    resources :triggers
    resources :coping_strategies
    resources :cats
    
    # Admin analytics
    get 'analytics', to: 'analytics#dashboard'
    get 'system_health', to: 'system#health'
  end
  
  # User profile and settings routes
  get 'profile', to: 'users#profile'
  patch 'profile', to: 'users#update_profile'
  get 'settings', to: 'users#settings'
  patch 'settings', to: 'users#update_settings'
  
  # Export and data management routes
  get 'export/data', to: 'data_export#index'
  post 'export/data', to: 'data_export#create'
  delete 'data/purge', to: 'data_management#purge'
  
  # Support and help routes
  get 'help', to: 'support#help'
  get 'contact', to: 'support#contact'
  post 'contact', to: 'support#create_message'
  get 'privacy', to: 'support#privacy'
  get 'terms', to: 'support#terms'
  
  # Webhooks and integrations
  namespace :webhooks do
    post 'stripe', to: 'stripe#handle'
    post 'notifications', to: 'notifications#handle'
  end
  
  # Custom routes for specific features
  
  # Mood tracking shortcuts
  get 'quick_mood', to: 'emotional_episodes#quick_log'
  post 'log_mood', to: 'emotional_episodes#create_quick'
  
  # Goal tracking shortcuts
  get 'goals', to: 'user_goals#index'
  get 'goals/new', to: 'user_goals#new'
  
  # Insights and recommendations
  get 'insights', to: 'insights#index'
  get 'recommendations', to: 'recommendations#index'
  
  # Social features (if implemented)
  resources :user_connections, only: [:index, :create, :destroy] do
    member do
      patch :accept
      patch :decline
    end
  end

  get '/social/challenges', to: 'social#challenges', as: 'social_challenges'
  
  # Notification management
  resources :notifications, only: [:index, :show, :update] do
    collection do
      patch :mark_all_read
    end
  end
  
  # Progressive Web App routes
  get 'manifest.json', to: 'pwa#manifest'
  get 'service-worker.js', to: 'pwa#service_worker'
  
  # Error handling routes
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all
end