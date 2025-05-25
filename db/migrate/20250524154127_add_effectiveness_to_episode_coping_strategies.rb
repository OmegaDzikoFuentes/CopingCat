class AddEffectivenessToEpisodeCopingStrategies < ActiveRecord::Migration[7.1]
  def change
    add_column :episode_coping_strategies, :effectiveness, :integer
  end
end
