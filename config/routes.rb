# config/routes.rb
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations'
  }
  
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
      post :use
    end
  end
  
  resources :diary_entries do
    collection do
      get :search
    end
  end
  
  resources :emotional_episodes do
    resources :physical_symptoms do
      collection do
        post :quick_add
      end
    end
    
    resources :behavior_reactions
    
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

  resources :questions 
  
  # Cat-related routes
  resources :cats do
    member do
      get :breathing
    end
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
  
  scope path: '/game', as: 'game' do
    # Main game dashboard - matches views/game/index.html.erb
    get '/', to: 'game#index', as: :root
    
    # 4 emotion question bubbles - matches views/game/questions.html.erb
    get 'questions', to: 'game#questions', as: :questions
    
    # Multi-step emotion form - matches views/game/emotion_mapping.html.erb
    get 'emotion-mapping', to: 'game#emotion_mapping', as: :emotion_mapping
    
    # Strategy results page - matches views/game/generate_strategy.html.erb
    get 'generate-strategy', to: 'game#generate_strategy', as: :generate_strategy
    
    # NEW: Tetris-like mindfulness game - matches views/game/over_stacked.html.erb
    get 'over-stacked', to: 'game#over_stacked', as: :over_stacked
    
    # Breathing exercise interface - matches views/game/breathing_exercise.html.erb
    get 'breathing-exercise', to: 'game#breathing_exercise', as: :breathing_exercise
    
    # Magic 8-ball game - matches views/game/magic_eight_ball.html.erb
    get 'magic-eight-ball', to: 'game#magic_eight_ball', as: :magic_eight_ball
    
    # Fortune telling game - matches views/game/fortune_teller.html.erb
    get 'fortune-teller', to: 'game#fortune_teller', as: :fortune_teller
    
    # Mood boosting activities - matches views/game/mood_booster.html.erb  
    get 'mood-booster', to: 'game#mood_booster', as: :mood_booster
    
    # POST routes for form submissions and game interactions
    post 'process-emotion-step', to: 'game#process_emotion_step', as: :process_emotion_step
    post 'generate-strategy', to: 'game#generate_strategy' # Handle POST to same action
    post 'magic-eight-ball', to: 'game#magic_eight_ball' # Handle question submissions
    post 'over-stacked/score', to: 'game#save_over_stacked_score', as: :save_over_stacked_score
    post 'breathing-exercise/complete', to: 'game#complete_breathing_exercise', as: :complete_breathing_exercise
  end
  
  # Helper routes for shared components
  get 'shared/cat-animation', to: 'shared#cat_animation', as: :shared_cat_animation
  
  # API routes
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'authentication#login'
      post 'auth/logout', to: 'authentication#logout'
      get 'auth/me', to: 'authentication#me'
      
      resources :emotional_episodes, only: [:index, :show, :create, :update] do
        resources :physical_symptoms, only: [:create, :destroy]
        
        member do
          patch :end_episode
        end
      end
      
      resources :emotions, only: [:index, :show]
      resources :triggers, only: [:index, :show]
      resources :coping_strategies, only: [:index, :show, :create]
      
      post 'quick_log', to: 'quick_log#create'
      
      get 'user/profile', to: 'users#profile'
      patch 'user/profile', to: 'users#update_profile'
      
      get 'analytics/summary', to: 'analytics#summary'
      get 'analytics/trends', to: 'analytics#trends'
      get 'analytics/insights', to: 'analytics#insights'
      
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
  
  # Admin routes
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
  
  # Mood tracking shortcuts
  get 'quick_mood', to: 'emotional_episodes#quick_log'
  post 'log_mood', to: 'emotional_episodes#create_quick'
  
  # Goal tracking shortcuts
  get 'goals', to: 'user_goals#index'
  get 'goals/new', to: 'user_goals#new'
  
  # Insights and recommendations
  get 'insights', to: 'insights#index'
  get 'recommendations', to: 'recommendations#index'
  
  # Social features
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