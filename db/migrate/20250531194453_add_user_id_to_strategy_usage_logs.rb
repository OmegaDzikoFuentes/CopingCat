class AddUserIdToStrategyUsageLogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :strategy_usage_logs, :user, null: false, foreign_key: true
  end
end
