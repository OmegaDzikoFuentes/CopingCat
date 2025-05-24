class EmotionalEpisodeEmotionsController < ApplicationController
    before_action :set_episode, except: [:index, :new, :create, :quick_log]
before_action :load_form_data, only: [:new, :edit]
end
