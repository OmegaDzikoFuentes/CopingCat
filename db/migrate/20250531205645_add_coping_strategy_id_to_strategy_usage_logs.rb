class AddCopingStrategyIdToStrategyUsageLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :strategy_usage_logs, :coping_strategy_id, :integer
    add_index :strategy_usage_logs, :coping_strategy_id
    add_foreign_key :strategy_usage_logs, :coping_strategies
  end
end
