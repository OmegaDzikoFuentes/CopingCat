class AddEffectivenessToEpisodeCopingStrategies < ActiveRecord::Migration[8.0]
  def change
    add_column :episode_coping_strategies, :effectiveness, :integer
  end
end
