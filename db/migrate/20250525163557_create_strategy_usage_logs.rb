class CreateStrategyUsageLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :strategy_usage_logs do |t|
      t.timestamps
    end
  end
end
